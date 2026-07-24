{
  description = "Validate and analyze Agent Skill packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: import nixpkgs { inherit system; };
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.buildGoModule {
            pname = "skill-validator";
            version = "1.5.6";

            src = self;
            vendorHash = "sha256-q8JRenRhDEzYO9Ub3SnDQ7phG0bWRJzDU2vPDllIrwU=";

            subPackages = [ "cmd/skill-validator" ];

            meta = {
              description = "Validate and analyze Agent Skill packages";
              homepage = "https://github.com/choplin/skill-validator";
              license = pkgs.lib.licenses.mit;
              mainProgram = "skill-validator";
            };
          };
        }
      );

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/skill-validator";
          meta.description = "Validate and analyze Agent Skill packages";
        };
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.go
              pkgs.golangci-lint
            ];
          };
        }
      );

      formatter = forAllSystems (system: (pkgsFor system).nixfmt-tree);
    };
}
