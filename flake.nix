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
            "${inputs.shell}/extra/services/postgres.nix"
            #            Boot.dev does not currently have rust content
            #            "${inputs.shell}/extra/language/rust.nix"
          ];

          env = [
            {
              name = "GOPATH";
              eval = "$PWD/go";
            }
            {
              name = "GOOSE_DRIVER";
              eval = "postgres";
            }
            {
              name = "GOOSE_DBSTRING";
              eval = "postgres://$USER@:/chirpy";
            }
            {
              name = "DOCKER_HOST";
              eval = "unix://$XDG_RUNTIME_DIR/docker.sock";
            }
          ];

          language = {
            c.compiler = pkgs.gcc;
            #            Boot.dev does not currently have rust content
            #            rust.packageSet = pkgs.rustPackages;
          };

          services.postgres = { };
          serviceGroups.docker.services = {
            docker.command = "dockerd-rootless";
          };

          commands = with pkgs; [
            {
              package = treefmt;
              category = "formatting";
            }
            {
              package = pkgs.callPackage buildGoModule rec {
                name = "bootdev";
                pname = name;
                version = "1.19.2";

                src = fetchFromGitHub {
                  owner = "bootdotdev";
                  repo = "bootdev";
                  rev = "v${version}";
                  # Hash for source files
                  sha256 = "sha256-jTI91t/gcEdOc3mwP0dFqL5sYeaC6nD96+RpuQfAf4s=";
                };

                # Hash post-build
                vendorHash = "sha256-jhRoPXgfntDauInD+F7koCaJlX4XDj+jQSe/uEEYIMM=";

                meta.description = "The official command line tool for Boot.dev. It allows you to submit lessons and do other such nonsense.";
              };
            }
            {
              package = curl;
              category = "testing";
            }
            {
              package = jq;
              category = "testing";
            }
            {
              package = goose;
              category = "databases";
            }
            {
              package = sqlc;
              category = "databases";
            }
            {
              package = minikube;
              category = "kubernetes";
            }
            {
              package = kubectl;
              category = "kubernetes";
            }
          ];

          devshell.packages = with pkgs; [
            # Formatting tools
            nixpkgs-fmt # Nix
            mdformat # Markdown
            black # Python
            sqlfluff # SQL
            taplo # TOML
            yamlfmt # YAML

            # Python packages
            (python3.withPackages (p: with p; [
              pygame # 6. Build Asteroids
            ]))

            # GoLang CGO
            libpcap

            nodejs
            typescript

            sqlite
            docker
          ];
        };
      };
    };
}
