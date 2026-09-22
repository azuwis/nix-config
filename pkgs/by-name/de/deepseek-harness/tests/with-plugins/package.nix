{
  lib,
  stdenv,
  deepseek-harness,
  runCommand,
  writableTmpDirAsHomeHook,
}:

# Boots a profile through `withPlugins` and checks the plugin modules ran.
# Catches a row the wrapper never inserts, a plugin whose own `@deepseek-ai/...`
# import cannot resolve, and a row that names a module directly.
let
  # Covers a plugin whose module is not the default `index.js`.
  plugin = runCommand "dsh-test-plugin" { passthru.entrypoint = "index.mjs"; } ''
    mkdir -p $out
    cp ${./plugin/index.mjs} $out/index.mjs
    ln -s ${deepseek-harness}/libexec/dsh/node_modules $out/node_modules
  '';

  wrapped = deepseek-harness.withPlugins [
    # A package, and a row that names a module directly.
    plugin
    {
      name = "${plugin}/index.mjs";
      id = "test-module";
    }
  ];
in

runCommand "deepseek-harness-with-plugins"
  {
    nativeBuildInputs = [
      wrapped
      writableTmpDirAsHomeHook
    ];
    # chokidar's native fs.watch fails with "EMFILE: too many open files"
    # in the darwin sandbox, use stat polling there.
    env.CHOKIDAR_USEPOLLING = lib.optionalString stdenv.hostPlatform.isDarwin "true";
  }
  ''
    cd "$HOME"

    # Booting the profile loads the plugins and then exits without a task.
    dsh --profile headless >boot.log 2>&1 || true
    loaded=$(grep -c 'test plugin loaded with function' boot.log || true)
    [ "$loaded" = 2 ] || {
      cat boot.log
      exit 1
    }

    echo "with-plugins test passed"
    touch $out
  ''
