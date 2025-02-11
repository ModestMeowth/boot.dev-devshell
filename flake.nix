{
  description = "Boot.dev Git Course";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    parts.url = "flake-parts";
    shell.url = "github:numtide/devshell";
    shell.inputs.nixpkgs.follows = "nixpkgs";
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
#            Boot.dev does not currently have rust content
#            "${inputs.shell}/extra/language/rust.nix"
          ];

          language = {
            c.compiler = pkgs.clang;
#            Boot.dev does not currently have rust content
#            rust.packageSet = pkgs.rustPackages;
          };

          commands = with pkgs; [
            {
              package = "treefmt";
            }
            {
              package = pkgs.callPackage buildGoModule rec {
                name = "bootdev";
                pname = name;
                version = "1.16.2";

                src = fetchFromGitHub {
                  owner = "bootdotdev";
                  repo = "bootdev";
                  rev = "v${version}";
                  # Hash for source files
                  sha256 = "sha256-WbHTs2dPNUSujZvqq02dhQLayxaz/WpfqPDejBz5zZI=";
                };

                # Hash post-build
                vendorHash = "sha256-jhRoPXgfntDauInD+F7koCaJlX4XDj+jQSe/uEEYIMM=";

                meta.description = "The official command line tool for Boot.dev. It allows you to submit lessons and do other such nonsense.";
              };
            }
          ];

          devshell.packages = with pkgs; [
            # Formatting tools
            nixpkgs-fmt # Nix
            mdformat    # Markdown
            black       # Python
            taplo       # TOML
            yamlfmt     # YAML

            # Python packages
            (python3.withPackages (p: with p; [
              pygame # 6. Build Asteroids
            ]))
          ];
        };
      };
    };
}
