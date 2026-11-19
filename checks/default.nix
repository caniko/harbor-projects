{
  harbor,
  pkgs,
}: let
  templateDocs = ../templates/default/docs;
in {
  site-acceptance = import ./site-acceptance.nix {inherit pkgs harbor;};
  docs = harbor.mkDocs {
    inherit pkgs;
    src = templateDocs;
    pname = "harbor-projects-template-docs";
  };

  summary = harbor.mkSummaryCheck {
    inherit pkgs;
    src = templateDocs;
  };
}
