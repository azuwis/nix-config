{
  all ? null,
  commit ? null,
  maintainer ? null,
  max-workers ? null,
  package ? null,
  path ? null,
  predicate ? null,
  prefix ? if all == "true" then builtins.toString ../. else null,
}:

let
  hasPrefix = prefix: str: builtins.substring 0 (builtins.stringLength prefix) str == prefix;
  getPosition = package: (builtins.unsafeGetAttrPos "src" package).file or package.meta.position;
in
(import <nixpkgs/maintainers/scripts/update.nix> {
  inherit
    commit
    maintainer
    max-workers
    package
    path
    ;
  include-overlays = [
    (import <nixpkgs/pkgs/top-level/by-name-overlay.nix> ../pkgs/by-name)
    (import ../overlays/default.nix)
  ];
  keep-going = true;
  predicate =
    if prefix != null then (_: package: hasPrefix prefix (getPosition package)) else predicate;
}).overrideAttrs
  (old: {
    shellHook =
      ''
        unset TZ
      ''
      + old.shellHook;
  })
