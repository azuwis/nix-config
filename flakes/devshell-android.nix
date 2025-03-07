{ inputs, ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      devshells.android-sdk =
        let
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

      devshells.android-emu =
        let
          emu = pkgs.androidenv.emulateApp {
            name = "android-emu";
            abiVersion = "armeabi-v7a"; # armeabi-v7a, mips, x86_64
          };
        in
        {
          packages = [
            emu
          ];
        };
    };
}
