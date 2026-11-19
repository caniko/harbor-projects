{harbor-meta}: {...}: {
  imports = [harbor-meta.treefmtModules.nix harbor-meta.treefmtModules.toml];
  projectRootFile = "flake.nix";
  settings.excludes = [
    ".github/workflows/*.yaml"
    "checks/fixtures/**"
    "templates/**"
    "tests/fixtures/**"
  ];
}
