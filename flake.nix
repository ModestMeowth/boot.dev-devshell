{
  inputs.nixpkgs.url = "nixpkgs";
  inputs.unstable.url = "unstable";

  inputs.shell.url = "devshell";
  inputs.parts.url = "flake-parts";

  outputs = inputs @ { ... }:
    inputs.parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.shell.flakeModule ];

      systems = inputs.nixpkgs.lib.systems.flakeExposed;

      perSystem = { pkgs, system, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            (final: _: {
              unstable = import inputs.unstable {
                inherit (final) system;
              };
            })
          ];
        };

        devshells.default = {
          devshell.packages = with pkgs; [
            # Formatters
            nixpkgs-fmt
            taplo
          ];

          commands = with pkgs; [
            {
              package = git;
            }
            {
              package = treefmt;
            }
            {
              package = pkgs.callPackage buildGoModule rec {
                name = "bootdev";
                pname = name;
                version = "1.11.0";
                vendorHash = "sha256-jhRoPXgfntDauInD+F7koCaJlX4XDj+jQSe/uEEYIMM=";
                meta.description = "The official command line tool for Boot.dev. It allows you to submit lessons and do other such nonsense.";
                src = fetchFromGitHub {
                  owner = "bootdotdev";
                  repo = "bootdev";
                  rev = "v${version}";
                  sha256 = "sha256-ZQW8UBm1oeo04dvBKB2MLrwbkV1hlxNVNiispuKJLMc=";
                };
              };
            }
          ];
        };
      };
    };
}
