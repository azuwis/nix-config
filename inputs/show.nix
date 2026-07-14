let
  allLock = import ./lock.nix;
in

let
  hasPrefix = pref: str: builtins.substring 0 (builtins.stringLength pref) str == pref;
  inputsList = builtins.attrValues (
    builtins.mapAttrs (
      name: value:
      value
      // {
        inherit name;
      }
    ) (import ./inputs.nix)
  );
  line = [
    "Name,Date,Rev,Cache,URL"
  ]
  ++ map (
    input:
    let
      inherit (input) name url;
      ref =
        if input ? ref then
          if hasPrefix "https://github.com/" url then
            "/tree/${input.ref}"
          else if hasPrefix "https://codeberg.org/" url then
            "/src/branch/${input.ref}"
          else
            "@${input.ref}"
        else
          "";
      lock = allLock.${name} or { };
      date =
        if lock ? lastModifiedDate then
          let
            s = builtins.substring;
            m = lock.lastModifiedDate;
          in
          "${s 0 4 m}-${s 4 2 m}-${s 6 2 m}"
        else
          "";
      rev = if lock ? shortRev then lock.shortRev else "";
      cache = if lock ? outPath && builtins.pathExists lock.outPath then "yes" else "";
    in
    "${name},${date},${rev},${cache},${url}${ref}"
  ) inputsList;
in
builtins.concatStringsSep "\n" line + "\n"
