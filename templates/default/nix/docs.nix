# Replace `my-project` / `caniko/my-project` throughout after init.
{
  pkgs,
  harborDocs,
}: {
  docs = harborDocs.mkDocs {
    inherit pkgs;
    src = ../docs;
    pname = "my-project-docs";
  };
}
