{
  pkgs ? import ../pkgs { },
  # nix-shell /etc/nixos/devshells/android-sdk.nix --arg studio true
  studio ? false,
  ...
}:

let
  inputs = import ../inputs;
  devshell = import inputs.devshell.outPath { nixpkgs = pkgs; };

  androidsdk =
    (pkgs.androidenv.composeAndroidPackages {
      # match `android.compileSdk` in app/build.gradle
      platformVersions = [ "34" ];
      # match `android.buildToolsVersion` in app/build.gradle
      buildToolsVersions = [ "34.0.0" ];
    }).androidsdk;
  androidHome = "${androidsdk}/libexec/android-sdk";
  gradle = pkgs.writeShellScriptBin "gradle" ''
    files=("$ANDROID_HOME"/build-tools/*/aapt2)
    file=''${files[0]}
    args=()
    if [ -e "$file" ]; then
      args=("-Dorg.gradle.project.android.aapt2FromMavenOverride=$file")
    fi
    ${pkgs.gradle}/bin/gradle "''${args[@]}" "$@"
  '';
in

devshell.mkShell {
  env = [
    {
      name = "ANDROID_HOME";
      value = androidHome;
    }
  ];
  packages = [
    androidsdk
    gradle
  ] ++ pkgs.lib.optionals studio [ (pkgs.android-studio.withSdk androidsdk) ];
}
