# Update all inputs:
# nix-instantiate --strict --eval --argstr update all default.nix | nixfmt > lock.tmp
# mv lock.tmp lock.nix

# Update some inputs:
# ... --argstr update "<input1> <input2> ..."
# Update all expect some inputs:
# ... --argstr update "all -<input1> -<input2> ..."
# Update some inputs to a specific revision:
# ... --argstr update "<input1>=<rev>"
# Update all and set some inputs to a specific revision
# ... --argstr update "all <input1>=<rev1> <input2>=<rev2> ..."

# Show:
# nix-instantiate --strict --eval --raw show.nix | column -s, -t

# Override input:
# NIXLOCK_OVERRIDE_<input1>="/home/user/src/<input1>" nix-build ...

# NOTE: Do not add `name` arg to fetchGit or fetchTarball, keep default name to
# `source`, which is special to nix. If changed, nix may copy inputs already in
# nix store when using `nix shell nixpkgs#foo` or similar commands
# https://github.com/NixOS/nix/issues/11228#issuecomment-2261087599
# `builtins.fetchGit` always fetch even if narHash provided.
# https://github.com/nikstur/lon/pull/3#issuecomment-2797643718

{
  update ? "",
}:

let
  allLock = import ./lock.nix;
  argsToString =
    args:
    builtins.concatStringsSep " " (
      [ "{" ]
      ++ builtins.attrValues (
        builtins.mapAttrs (
          name: value:
          let
            valueString =
              if builtins.isBool value then
                if value then "true" else "false"
              else if builtins.isInt value then
                toString value
              else
                "\"${toString value}\"";
          in
          "${name}=${valueString};"
        ) args
      )
      ++ [ "}" ]
    );
  hasPrefix = pref: str: builtins.substring 0 (builtins.stringLength pref) str == pref;
  updateTargets = builtins.filter builtins.isString (builtins.split " " update);
  # Parse <input>=<rev> entries
  updateRevs = builtins.listToAttrs (
    builtins.concatMap (
      target:
      let
        parts = builtins.match "([^=]+)=(.+)" target;
      in
      if parts != null then
        [
          {
            name = builtins.elemAt parts 0;
            value = builtins.elemAt parts 1;
          }
        ]
      else
        [ ]
    ) updateTargets
  );
in

builtins.mapAttrs (
  name: input:
  let
    lock = allLock.${name} or { };
    isLocked =
      if lock == { } then
        false
      else if updateRevs ? ${name} then
        false
      else if builtins.elem name updateTargets then
        false
      else if builtins.elem "-${name}" updateTargets then
        true
      else if builtins.elem "all" updateTargets then
        input.freeze or false
      else
        true;
    fetchGitArgs = {
      shallow = true;
    }
    // removeAttrs input [
      "freeze"
    ]
    // (
      if isLocked then
        removeAttrs lock [
          "lastModifiedDate"
          "outPath"
          "shortRev"
        ]
      else if updateRevs ? ${name} then
        { rev = updateRevs.${name}; }
      else
        { }
    );
    fetchInput = builtins.trace "[1;33m${name} = builtins.fetchGit ${argsToString fetchGitArgs}[0m" (
      builtins.fetchGit fetchGitArgs
    );
    nixlockOverrideEnv = "NIXLOCK_OVERRIDE_${builtins.replaceStrings [ "-" ] [ "_" ] name}";
    replacement = builtins.getEnv nixlockOverrideEnv;
  in
  if replacement != "" then
    # https://github.com/andir/npins/blob/5eb1bde1898a3c32a3aacb36ae120897a58c9ed8/src/default.nix#L36
    # Override with a path defined in an environment variable.
    let
      # this turns the string into an actual Nix path (for both absolute and
      # relative paths)
      outPath =
        if builtins.substring 0 1 replacement == "/" then
          /. + replacement
        else
          /. + builtins.getEnv "PWD" + "/${replacement}";
    in
    lock
    //
      builtins.trace
        "Overriding path of \"${name}\" with \"${toString outPath}\" due to set ${nixlockOverrideEnv}"
        { inherit outPath; }
  else if isLocked then
    lock
    // {
      outPath =
        if hasPrefix "https://github.com/" input.url || hasPrefix "https://codeberg.org/" input.url then
          # For sites that provide tarballs, use fetchTarball with sha256, it
          # is content-addressed, no-op if the output already exists. Don't
          # check pathExists first: it looks at the filesystem, but import
          # checks the Nix DB. The two can disagree in CI when the cache is
          # restored.
          builtins.fetchTarball {
            url = input.url + "/archive/" + lock.rev + ".tar.gz";
            sha256 = lock.narHash;
          }
        else if builtins.pathExists lock.outPath then
          # pathExists looks at the filesystem, not the Nix DB. For git inputs
          # we keep this for performance rather than correctness, because
          # fetchGit always refetches even when the rev is already cached.
          builtins.appendContext lock.outPath {
            "${lock.outPath}" = {
              path = true;
            };
          }
        else
          # Fallback to fetchGit
          fetchInput.outPath;
    }
  else
    fetchInput
) (import ./inputs.nix)
