import subprocess
import shutil
from pathlib import Path
import os
import sys
import tempfile
from typing import TypeVar, List


def exit_error(error: str):
    print(error)
    exit(1)


def strip_home(path: Path) -> Path:
    home = Path.home()
    try:
        return path.relative_to(home)
    except ValueError:
        # Path is not under home
        return path


def get_hostname():
    import subprocess

    # Try reading /etc/hostname
    try:
        with open("/etc/hostname", "r") as f:
            return f.read().strip()
    except (FileNotFoundError, PermissionError):
        pass

    # Try calling the hostname command
    try:
        result = subprocess.run(
            ["hostname"], capture_output=True, text=True, check=True
        )
        return result.stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass

    # Both methods failed
    exit_error(
        "unable to determine hostname: /etc/hostname not readable and 'hostname' command failed"
    )


T = TypeVar("T")


def require_index(array: List[T], index: int, error: str) -> T:
    try:
        item = array[index]
        return item
    except IndexError:
        # can't use exit_error here without it throwing off the type checking
        print(error)
        exit(1)


def expand_realtive_path(path: Path | str) -> Path:
    p = Path(path).expanduser()

    if not p.is_absolute():
        p = Path.cwd() / p

    return Path(os.path.normpath(p))


def import_path(path: str, is_host_specific: bool, is_secret: bool):
    src_path = expand_realtive_path(path)
    if not src_path.exists():
        exit_error("given path does not exist")
    if is_secret and src_path.is_dir():
        exit_error("cannot import a directory as a secret file")
    print(src_path)

    if not src_path.is_relative_to(Path.home()):
        exit_error("Can only import paths that live in your home dir")

    home_relative_path = strip_home(src_path)

    target_path = Path(".")
    if is_secret:
        target_path = target_path / "secrets"

    if is_host_specific:
        hostname = get_hostname()
        target_path = target_path / "host_specific" / hostname
    else:
        target_path = target_path / "all"

    target_path = target_path / home_relative_path

    if target_path.exists():
        exit_error("path already exists in dotfiles")

    print(f"importing: {src_path} to {target_path}")

    target_path.parent.mkdir(parents=True, exist_ok=True)

    if is_secret:
        # For secrets: copy to temp, encrypt to repo, decrypt back to source
        temp_path = target_path.with_suffix(target_path.suffix + ".tmp")
        encrypted_path = target_path.with_suffix(target_path.suffix + ".age")
        shutil.copy2(src_path, temp_path)
        encrypt_file(temp_path, encrypted_path)
        temp_path.unlink()
        # Decrypt back to original location for the app to use
        decrypt_file(encrypted_path, src_path)
    else:
        # For plaintext: copy and symlink
        shutil.copy2(src_path, target_path)
        if src_path.is_dir():
            src_path.rmdir()
        else:
            src_path.unlink()
        src_path.symlink_to(target_path.resolve())


def encrypt_file(src: Path, target: Path):
    try:
        subprocess.run(
            [
                "age",
                "-R",
                os.path.expanduser("~/.ssh/id_ed25519.pub"),
                "-o",
                str(target),
                str(src),
            ],
            capture_output=True,
            text=True,
            check=True,
        )
    except subprocess.CalledProcessError as e:
        print(
            f"encryption failed: {e.stderr or e.stdout or 'unknown error'}",
            file=sys.stderr,
        )
        exit(1)


def decrypt_file(src: Path, target: Path):
    try:
        subprocess.run(
            [
                "age",
                "-d",
                "-i",
                os.path.expanduser("~/.ssh/id_ed25519"),
                "-o",
                str(target),
                str(src),
            ],
            capture_output=True,
            text=True,
            check=True,
        )
    except subprocess.CalledProcessError as e:
        print(
            f"decryption failed: {e.stderr or e.stdout or 'unknown error'}",
            file=sys.stderr,
        )
        exit(1)


def edit_secret_file(path):
    target_path = Path(path).resolve()
    ssh_key = os.path.expanduser("~/.ssh/id_ed25519")
    editor = os.environ.get("EDITOR", "vi")

    # Create temp file
    with tempfile.NamedTemporaryFile(mode="w", suffix=".age-edit", delete=False) as tmp:
        tmp_path = Path(tmp.name)

    try:
        # If target exists, decrypt it to temp file
        if target_path.exists():
            decrypt_file(target_path, tmp_path)
        else:
            # Create empty file
            tmp_path.write_text("")

        # Open editor
        subprocess.run([editor, str(tmp_path)], check=True)

        # Re-encrypt to target
        target_path.parent.mkdir(parents=True, exist_ok=True)
        encrypt_file(tmp_path, target_path)

        print(f"Saved encrypted file to {target_path}")
    finally:
        # Cleanup
        if tmp_path.exists():
            tmp_path.unlink()


def dispatch(args: List[str]):
    action = args[1]
    is_host_specific = "--host" in args
    is_secret = "--secret" in args

    match action:
        case "import":
            path = require_index(args, 2, "path required argument")
            import_path(path, is_host_specific, is_secret)
        case "edit-secret-file":
            path = require_index(args, 2, "path required argument")
            edit_secret_file(path)
        case _:
            print("action not found")


if __name__ == "__main__":
    if shutil.which("age") is None:
        exit_error("age cli must be available")
    dispatch(sys.argv)
