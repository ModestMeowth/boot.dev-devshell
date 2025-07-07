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
              package = pkgs.bootdev-cli;
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
