{
  lib,
  stdenv,
  deepseek-harness,
  runCommand,
  writableTmpDirAsHomeHook,
}:

# Installs that plugin into the headless profile, then boots it to prove the
# installed layer loads. Catches a broken pnpm forwarder, a broken bundle
# reconcile, and a broken profile module fallback for out-of-tree plugins.
runCommand "deepseek-harness-plugin-install"
  {
    nativeBuildInputs = [
      deepseek-harness
      writableTmpDirAsHomeHook
    ];
    # chokidar's native fs.watch fails with "EMFILE: too many open files"
    # in the darwin sandbox, use stat polling there.
    env.CHOKIDAR_USEPOLLING = lib.optionalString stdenv.hostPlatform.isDarwin "true";
  }
  ''
    cd "$HOME"

    dsh plugin --profile headless install file:${./package}

    # Booting the profile loads the plugin and then exits without a task.
    dsh --profile headless >boot.log 2>&1 || true
    grep -q 'loaded with cordis function' boot.log || {
      cat boot.log "$HOME/.dsh/profiles/headless/package.json"
      exit 1
    }

    echo "plugin-install test passed"
    touch $out
  ''
