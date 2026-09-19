{...}: {
  # Fails when a docs/src/*.md file is not referenced from SUMMARY.md.
  # src is the consumer's docs/ dir.
  mkSummaryCheck = {
    pkgs,
    src,
    name ? "docs-summary",
  }:
    pkgs.runCommand name {
      inherit src;
    } ''
      missing=0
      while IFS= read -r -d "" file; do
        base="$(basename "$file")"
        if ! grep -q -- "$base" "$src/src/SUMMARY.md"; then
          echo "docs-summary: $file not referenced from SUMMARY.md" >&2
          missing=1
        fi
      done < <(find "$src/src" -name "*.md" ! -name "SUMMARY.md" -print0)
      if [ "$missing" -ne 0 ]; then
        exit 1
      fi
      mkdir -p "$out"
    '';
}
