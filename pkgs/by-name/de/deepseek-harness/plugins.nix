{
  lib,
  deepseek-harness,
  makeBinaryWrapper,
  runCommandLocal,
  writeText,
}:

# `deepseek-harness.withPlugins [ … ]` wraps `dsh` with a `--patch` layer that
# activates one row per entry: a package whose `entrypoint` (`index.js` unless
# `entrypoint` names another) is the plugin module, or a ready-made `{ id; name; }`
# row for a module that has no package of its own, such as one inside the harness.
plugins:

let
  entrypointOf = plugin: plugin.entrypoint or "index.js";

  # JSON is YAML, and the launcher parses patch files as YAML.
  patch = writeText "dsh-plugins.patch.yml" (
    builtins.toJSON [
      {
        insert = map (
          entry:
          if lib.isDerivation entry then
            {
              name = "${entry}/${entrypointOf entry}";
              id = lib.getName entry;
            }
          else
            entry
        ) plugins;
      }
    ]
  );
in

runCommandLocal "deepseek-harness-with-plugins-${deepseek-harness.version}"
  {
    inherit (deepseek-harness) meta;
    nativeBuildInputs = [ makeBinaryWrapper ];
  }
  ''
    ${lib.concatMapStrings (entry: ''
      test -f ${entry}/${entrypointOf entry}
    '') (builtins.filter lib.isDerivation plugins)}
    mkdir -p $out/bin
    makeBinaryWrapper ${lib.getExe deepseek-harness} $out/bin/dsh \
      --add-flags "--patch ${patch}"
  ''
