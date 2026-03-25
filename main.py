#!/usr/bin/env python3

import argparse
import os
import shutil
import sys
from pathlib import Path


def replace_symlink(link_path: Path, dry_run: bool = False, verbose: bool = False) -> None:
    try:
        if not link_path.is_symlink():
            return

        target = link_path.resolve(strict=True)

        if verbose or dry_run:
            print(f"{'[DRY RUN] ' if dry_run else ''}Replacing symlink: {link_path} -> {target}")

        if dry_run:
            return

        # Remove the symlink itself, not the target
        link_path.unlink()

        if target.is_dir():
            shutil.copytree(target, link_path, symlinks=False)
        elif target.is_file():
            shutil.copy2(target, link_path)
        else:
            print(f"Skipping unsupported target type: {link_path} -> {target}", file=sys.stderr)

    except FileNotFoundError:
        print(f"Skipping broken symlink: {link_path}", file=sys.stderr)
    except Exception as e:
        print(f"Error processing {link_path}: {e}", file=sys.stderr)


def walk_and_replace(root: Path, dry_run: bool = False, verbose: bool = False) -> None:
    # Gather symlinks first so we don't mutate while walking
    symlinks = []

    for dirpath, dirnames, filenames in os.walk(root, topdown=True, followlinks=False):
        current_dir = Path(dirpath)

        for name in dirnames + filenames:
            path = current_dir / name
            if path.is_symlink():
                symlinks.append(path)

    for symlink in symlinks:
        replace_symlink(symlink, dry_run=dry_run, verbose=verbose)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Replace symlinks in a directory with real copies of their targets."
    )
    parser.add_argument("directory", help="Root directory to scan")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be changed without modifying anything",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Print each symlink as it is processed",
    )

    args = parser.parse_args()
    root = Path(args.directory).expanduser().resolve()

    if not root.exists():
        print(f"Error: directory does not exist: {root}", file=sys.stderr)
        sys.exit(1)

    if not root.is_dir():
        print(f"Error: not a directory: {root}", file=sys.stderr)
        sys.exit(1)

    walk_and_replace(root, dry_run=args.dry_run, verbose=args.verbose)


if __name__ == "__main__":
    main()
