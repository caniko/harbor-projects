{
  description = "My Project docs — powered by harbor-docs";

  inputs = {
    harbor-docs.url = "github:caniko/harbor-docs";

    nixpkgs.follows = "harbor-docs/nixpkgs";
    harbor-meta.follows = "harbor-docs/harbor-meta";
    treefmt-nix.follows = "harbor-docs/treefmt-nix";
  };

  outputs = {
    self,
    nixpkgs,
    harbor-docs,
    harbor-meta,
    treefmt-nix,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forSystem = system: let
      pkgs = import nixpkgs {inherit system;};
      packages = import ./nix/docs.nix {
        inherit pkgs;
        harborDocs = harbor-docs.lib;
      };
      treefmt = treefmt-nix.lib.evalModule pkgs {
        imports = [harbor-meta.treefmtModules.nix harbor-meta.treefmtModules.toml];
        projectRootFile = "flake.nix";
      };
    in {inherit pkgs packages treefmt;};
  in {
    packages = nixpkgs.lib.genAttrs systems (system: {
      docs = (forSystem system).packages.docs;
    });

    devShells = nixpkgs.lib.genAttrs systems (system: let
      env = forSystem system;
    in {
      default = env.pkgs.mkShell {
        packages = [env.pkgs.mdbook];
        shellHook = ''
          echo "Documentation: mdbook serve docs"
        '';
      };
    });

    checks = nixpkgs.lib.genAttrs systems (system: let
      env = forSystem system;
    in {
      docs = env.packages.docs;
      summary = harbor-docs.lib.mkSummaryCheck {
        pkgs = env.pkgs;
        src = ./docs;
      };
      formatting = env.treefmt.config.build.check self;
    });

    formatter = nixpkgs.lib.genAttrs systems (system: (forSystem system).treefmt.config.build.wrapper);
  };
}
