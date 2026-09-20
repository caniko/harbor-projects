{
  self,
  harbor,
  pkgs,
  treefmt-nix,
  harborMeta,
}: let
  templateDocs = ../templates/default/docs;
  treefmt = treefmt-nix.lib.evalModule pkgs {
    imports = [harborMeta.treefmtModules.nix harborMeta.treefmtModules.toml];
    projectRootFile = "flake.nix";
  };
in {
  docs = harbor.mkDocs {
    inherit pkgs;
    src = templateDocs;
    pname = "harbor-projects-template-docs";
  };

  summary = harbor.mkSummaryCheck {
    inherit pkgs;
    src = templateDocs;
  };

  formatting = treefmt.config.build.check self;
}
