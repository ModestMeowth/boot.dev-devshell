{
  description = "Boot.dev Git Course";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    parts.url = "flake-parts";
    shell.url = "devshell";
  };

  outputs = inputs @ { ... }:
    inputs.parts.lib.mkFlake { inherit inputs; } {
      systems = inputs.nixpkgs.lib.systems.flakeExposed;

      imports = [
        inputs.shell.flakeModule
      ];

      perSystem = { lib, pkgs, system, ... }: {
        devshells.default = {
          imports = [
            "${inputs.shell}/extra/language/c.nix"
            "${inputs.shell}/extra/language/go.nix"
            "${inputs.shell}/extra/language/rust.nix"
          ];

          language = {
            c.compiler = pkgs.clang;
            rust.packageSet = pkgs.rustPackages;
          };

          commands = with pkgs; [
            {
              package = "treefmt";
            }
            {
              package = pkgs.callPackage buildGoModule rec {
                name = "bootdev";
                pname = name;
                version = "1.16.1";

                src = fetchFromGitHub {
                  owner = "bootdotdev";
                  repo = "bootdev";
                  rev = "v${version}";
                  sha256 = "sha256-e6LUAcG0tCTfRWGkJ85jIfjcr4/1fIP61rPPUTDrkjg=";
                };

                vendorHash = "sha256-jhRoPXgfntDauInD+F7koCaJlX4XDj+jQSe/uEEYIMM=";

                meta.description = "The official command line tool for Boot.dev. It allows you to submit lessons and do other such nonsense.";
              };
            }
          ];

          devshell.packages = with pkgs; [
            nixpkgs-fmt
            mdformat
            black
            taplo
            (python3.withPackages (p: with p; [
              pygame
            ]))
          ];
        };
      };
    };
}
