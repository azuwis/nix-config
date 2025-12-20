let
  lockFile = import ./lock.lock;
  inputsFile = import ./inputs.nix;
in

let
  inputsList = builtins.attrValues (
    builtins.mapAttrs (
      name: value:
      value
      // {
        inherit name;
      }
    ) inputsFile
  );
  line = map (
    input:
    let
      inherit (input) name;
      url = builtins.replaceStrings [ "https://github.com/" ] [ "github:" ] input.url;
      ref = if input ? ref then "@${input.ref}" else "";
      lock = lockFile.${name} or { };
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
    in
    "${name} ${date} ${rev} ${url}${ref}"
  ) inputsList;
in
builtins.concatStringsSep "\n" line
