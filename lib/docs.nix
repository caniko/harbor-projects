{...}: rec {
  # Opinionated book.toml text. Mirrors the harbor-rs docs setup: coal dark
  # theme, site-url for the merged /docs/ mount, edit links to trunk.
  mkBookToml = {
    title,
    repo,
    siteUrl,
    authors ? ["caniko"],
    src ? "src",
    language ? "en",
  }: ''
    [book]
    title = ${builtins.toJSON title}
    authors = ${builtins.toJSON authors}
    language = ${builtins.toJSON language}
    src = ${builtins.toJSON src}

    [build]
    build-dir = "book"

    [output.html]
    site-url = ${builtins.toJSON siteUrl}
    default-theme = "coal"
    preferred-dark-theme = "coal"
    git-repository-url = ${builtins.toJSON "https://github.com/${repo}"}
    edit-url-template = ${builtins.toJSON "https://github.com/${repo}/edit/trunk/docs/{path}"}
  '';

  # mdBook build derivation. src is the consumer's docs/ dir (book.toml +
  # src/), passed through unfiltered exactly like the proven harbor-rs block.
  # bookToml (a store path) overrides docs/book.toml when given.
  # NOTE: the null-bookToml phases are byte-identical to harbor-rs
  # nix/site.nix so adopting repos keep identical derivation hashes.
  mkDocs = {
    pkgs,
    src,
    bookToml ? null,
    pname ? "project-docs",
    version ? "0.1.0",
  }:
    pkgs.stdenv.mkDerivation {
      inherit pname version src;
      nativeBuildInputs = [pkgs.mdbook];
      phases = ["buildPhase" "installPhase"];
      buildPhase =
        ''
          cp -r --no-preserve=mode $src docs
          chmod -R u+w docs
        ''
        + pkgs.lib.optionalString (bookToml != null) ''
          cp ${bookToml} docs/book.toml
        ''
        + ''
          mdbook build docs
        '';
      installPhase = ''
        mkdir -p $out
        cp -r docs/book/. $out/
      '';
    };

  # Plinth site wrapper: merges the built book at /docs/ via docsPackage.
  mkSite = {
    projectSiteLib,
    pname,
    domain,
    configPath,
    staticPaths ? [],
    docs,
    version ? "0.1.0",
  }:
    projectSiteLib.mkProjectSite {
      inherit pname version domain configPath staticPaths;
      docsPackage = docs;
    };

  # Docs dev shell. plinthProject comes from the consumer's plinth input;
  # harbor-docs deliberately does not pin plinth itself.
  mkDocsDevShell = {
    pkgs,
    plinthProject,
    extraPackages ? [],
  }:
    pkgs.mkShell {
      packages = [pkgs.mdbook plinthProject] ++ extraPackages;
      shellHook = ''
        echo "Documentation: mdbook serve docs"
        echo "Project site: plinth-project serve --config website/plinth-project.toml --out website/.plinth-project/public"
      '';
    };
}
