# Replace `my-project` / `caniko/my-project` throughout after init.
{
  pkgs,
  lib,
  projectSiteLib,
  harborDocs,
}: let
  docs = harborDocs.mkDocs {
    inherit pkgs;
    src = ../docs;
    pname = "my-project-docs";
  };

  website = harborDocs.mkSite {
    inherit projectSiteLib docs;
    pname = "my-project-website";
    domain = "my-project.tartanoglu.com";
    configPath = ../website/plinth-project.toml;
    staticPaths = [
      {
        source = ../website/static/my-project-mark.svg;
        target = "website/static/my-project-mark.svg";
      }
    ];
  };
in {
  inherit docs website;
  site = website;
}
