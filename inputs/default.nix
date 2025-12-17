# https://codeberg.org/FrdrCkII/nixlock

let
  # https://github.com/nikstur/lon/blob/main/lon.nix
  # Override with a path defined in an environment variable. If no variable is
  # set, the original path is used.
  overrideFromEnv =
    name: path:
    let
      replacement = builtins.getEnv "NIXLOCK_OVERRIDE_${name}";
    in
    if replacement == "" then
      path
    else
      # this turns the string into an actual Nix path (for both absolute and
      # relative paths)
      path
      // {
        outPath =
          if builtins.substring 0 1 replacement == "/" then
            /. + replacement
          else
            /. + builtins.getEnv "PWD" + "/${replacement}";
      };
in
builtins.mapAttrs overrideFromEnv (import ./lock.nix { })
