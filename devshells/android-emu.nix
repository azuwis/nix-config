{
  pkgs ? import ../pkgs { },
  ...
}:

let
  inputs = import ../inputs;
  devshell = import inputs.devshell.outPath { nixpkgs = pkgs; };

  emu = pkgs.androidenv.emulateApp {
    name = "android-emu";
    abiVersion = "armeabi-v7a"; # armeabi-v7a, mips, x86_64
  };
in

devshell.mkShell {
  packages = [
    emu
  ];
}
