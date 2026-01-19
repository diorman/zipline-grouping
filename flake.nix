{
  description = "Project dev environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/72ac591e737060deab2b86d6952babd1f896d7c5";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.gnumake
            pkgs.ruby_3_4
          ];
        };
      }
    );
}
