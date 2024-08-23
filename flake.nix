{
  description = "Neovim environment with Lua tools";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";  # Change this if you're on a different architecture
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system} = {
        default = pkgs.mkShell {
          buildInputs = [
            pkgs.stylua
            pkgs.lua-language-server
          ];
        };
      };
    };
}

