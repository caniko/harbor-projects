{...}: rec {
  docs = import ./docs.nix {};
  checks = import ./checks.nix {};

  inherit (docs) mkBookToml mkDocs mkSite mkDocsDevShell;
  inherit (checks) mkSummaryCheck mkWebsiteMarkers;
}
