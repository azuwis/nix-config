{
  lib,
  bash,
  buildFHSEnv,
  file,
  git,
  makeSetupHook,
  ncurses,
  perl,
  python3,
  rsync,
  unzip,
  util-linux,
  wget,
  which,
  zlib,
  zstd,
}:

let
  openwrtFhs = buildFHSEnv {
    name = "openwrt-sdk-fhs";
    targetPkgs = pkgs: [
      bash
      file
      git
      ncurses
      ncurses.dev
      perl
      python3
      rsync
      unzip
      util-linux
      wget
      which
      zlib
      zstd
    ];
  };
in

makeSetupHook {
  name = "openwrt-fhs-hook";
  substitutions = {
    openwrtFhs = lib.getExe openwrtFhs;
  };
} ./openwrt-fhs-hook.sh
