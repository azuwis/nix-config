{
  all ? null,
  commit ? null,
  maintainer ? null,
  max-workers ? null,
  output-json ? null,
  package ? null,
  path ? null,
  predicate ? null,
  prefix ? null,
  skip-prompt ? "true",
}:

let
  inherit (pkgs) lib;
  pkgs = import ../default.nix { };
  nixpkgs = pkgs.inputs.nixpkgs.outPath;
  getPosition = package: (builtins.unsafeGetAttrPos "src" package).file or package.meta.position;
  pkgHasPrefix = prefix: package: lib.hasPrefix prefix (getPosition package);
in
(import "${nixpkgs}/maintainers/scripts/update.nix" {
  inherit
    commit
    maintainer
    max-workers
    package
    path
    skip-prompt
    ;
  include-overlays = [
    (import "${nixpkgs}/pkgs/top-level/by-name-overlay.nix" ../pkgs/by-name)
    (import ../overlays/default.nix)
  ];
  keep-going = "true";
  predicate =
    if all == "true" then
      (
        _: package:
        pkgHasPrefix (builtins.toString ../.) package && !(package ? skipUpdate && package.skipUpdate)
      )
    else if prefix != null then
      (_: package: pkgHasPrefix prefix package)
    else
      predicate;
}).overrideAttrs
  (old: {
    shellHook =
      # Retain git commit timezone
      ''
        unset TZ
      ''
      + lib.optionalString (output-json == "true") ''
        json_file=$(echo "$shellHook" | grep -o '/nix/store/[0-9a-z]\+-packages.json')
        if [ -e "$json_file" ]
        then
          cat "$json_file"
        fi
        exit
      ''
      + old.shellHook;
  })
