# Inspired by https://codeberg.org/FrdrCkII/nixlock

# Update all inputs:
# NIXLOCK_UPDATE=all nix-instantiate --strict --eval default.nix | nixfmt > lock.tmp
# mv lock.tmp lock.nix

# Update some inputs:
# NIXLOCK_UPDATE="<input1> <input2>" ...
# Update all expect some inputs:
# NIXLOCK_UPDATE="all -<input1> -<input2>" ...

# Show:
# nix-instantiate --strict --eval --raw show.nix | column -s, -t

# Override input:
# NIXLOCK_OVERRIDE_<input1>="/home/user/src/<input1>" nix-build ...

# NOTE: Do not add `name` arg to fetchGit or fetchTarball, keep default name to
# `source`, which is special to nix. If changed, nix may copy inputs already in
# nix store when using `nix shell nixpkgs#foo` or similar commands
# https://github.com/NixOS/nix/issues/11228#issuecomment-2261087599

let
  allLock = import ./lock.nix;
  argsToString =
    args:
    builtins.concatStringsSep "" (
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
  updateTargets = builtins.filter builtins.isString (
    builtins.split " " (builtins.getEnv "NIXLOCK_UPDATE")
  );
  updateAll = builtins.elem "all" updateTargets;
  needUpdate =
    name:
    if builtins.elem name updateTargets then
      true
    else if builtins.elem "-${name}" updateTargets then
      false
    else
      updateAll;
in

builtins.mapAttrs (
  name: input:
  let
    lock = allLock.${name} or { };
    isLocked = needUpdate name == false && lock != { };
    fetchGitArgs = {
      shallow = true;
    }
    // removeAttrs input [ "type" ]
    // (
      if isLocked then
        removeAttrs lock [
          "lastModifiedDate"
          "outPath"
          "shortRev"
        ]
      else
        { }
    );
    fetchInput = builtins.trace "${name} = builtins.fetchGit ${argsToString fetchGitArgs}" (
      builtins.fetchGit fetchGitArgs
    );
    replacement = builtins.getEnv "NIXLOCK_OVERRIDE_${name}";
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
        "Overriding path of \"${name}\" with \"${toString outPath}\" due to set NIXLOCK_OVERRIDE_${name}"
        { inherit outPath; }
  else if input.type == "archive" then
    if isLocked then
      lock
      // {
        outPath = builtins.fetchTarball {
          url = input.url + "/archive/" + lock.rev + ".tar.gz";
          sha256 = lock.narHash;
        };
      }
    else
      fetchInput
  else if input.type == "git" then
    if isLocked then
      lock
      // {
        # Hack here, builtins.fetchGit always fetch even if narHash provided,
        # use fetchTarball to produce the outPath if already in nix store
        # https://github.com/nikstur/lon/pull/3#issuecomment-2797643718
        outPath =
          if builtins.pathExists lock.outPath then
            builtins.fetchTarball {
              url = "";
              sha256 = lock.narHash;
            }
          else
            fetchInput.outPath;
        # If the problem fixed in nix, should use the following code instead
        # inherit (fetchInput) outPath;
      }
    else
      fetchInput
  else
    { }
) (import ./inputs.nix)
