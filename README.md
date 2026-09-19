# harbor-docs

Reusable mdBook + plinth-project documentation infrastructure for Nix flakes.

`harbor-docs` owns the boring docs plumbing so consuming flakes keep project
policy local: book layout, build derivation, plinth `docsPackage` merge,
dev shell, and doc checks live here; titles, content, and domains stay with
each consumer.

## Usage

```nix
{
  inputs.harbor-docs.url = "github:caniko/harbor-docs";
}
```

```nix
# nix/site.nix
{
  pkgs,
  projectSiteLib,
  harborDocs,
}: {
  docs = harborDocs.mkDocs {
    inherit pkgs;
    src = ../docs;
    pname = "my-project-docs";
  };

  site = harborDocs.mkSite {
    inherit pkgs projectSiteLib;
    domain = "my-project.tartanoglu.com";
    configPath = ../website/plinth-project.toml;
    docs = self.docs; # via packages wiring
    staticPaths = [
      {
        source = ../website/static/my-mark.svg;
        target = "website/static/my-mark.svg";
      }
    ];
  };
}
```

Or scaffold a new docs tree:

```bash
nix flake init -t github:caniko/harbor-docs
```

## API

- `mkBookToml { title, repo, siteUrl, authors ?, src ? }` — opinionated
  `book.toml` text (coal dark theme, `edit-url-template` to
  `.../edit/trunk/docs/{path}`).
- `mkDocs { pkgs, src, bookToml ?, pname ?, version ? }` — `mdbook build`
  derivation; `$out` is the built book. Pass `bookToml` (a store path) to
  override the consumer's `docs/book.toml`.
- `mkSite { projectSiteLib, domain, configPath, staticPaths ?, docs, pname ?, version ? }` —
  thin wrapper over `mkProjectSite { docsPackage = docs; }` so the built book
  lands at `$out/docs/`.
- `mkDocsDevShell { pkgs, plinthProject, extraPackages ? }` — `mdbook` +
  `plinth-project` shell (`plinthProject` comes from the consumer's plinth
  input; harbor-docs does not pin plinth itself).
- `mkSummaryCheck { pkgs, src }` — fails when a `docs/src/*.md` file is not
  reachable from `SUMMARY.md`.
