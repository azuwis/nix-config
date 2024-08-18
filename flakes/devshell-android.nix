{ inputs, ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      devshells.android =
        let
          androidsdk =
            (pkgs.androidenv.composeAndroidPackages {
              # match `android.compileSdk` in build.gradle
              platformVersions = [ "34" ];
            }).androidsdk;
          androidHome = "${androidsdk}/libexec/android-sdk";
          gradle = pkgs.writeShellScriptBin "gradle" ''
            files=("$ANDROID_HOME"/build-tools/*/aapt2)
            file=''${files[0]}
            args=()
            if [ -e "$file" ]; then
              args=("-Dorg.gradle.project.android.aapt2FromMavenOverride=$file")
            fi
            ${pkgs.gradle}/bin/gradle "''${args[$@]}" "$@"
          '';
        in
        {
          env = [
            {
              name = "ANDROID_HOME";
              value = androidHome;
            }
          ];
          packages = [
            androidsdk
            gradle
          ];
        };
    };
}