# https://nixos.org/manual/nixpkgs/stable/#sec-config-options-reference
# Can be use as `~/.config/nixpkgs/config.nix`.
# Also used by `common/nixpkgs/default.nix` `pkgs/default.nix`

let
  inputs = import ./inputs;
  lib = import ./lib;
  _cuda = import (inputs.nixpkgs.outPath + "/pkgs/development/cuda-modules/_cuda/default.nix");
in

{
  allowAliases = false;
  allowUnfreePredicate = (
    pkg:
    builtins.elem (lib.getName pkg) [
      "libretro-genesis-plus-gx"
      "nvidia-settings"
      "nvidia-x11"
      "steam"
      "steam-jupiter-unwrapped"
      "steam-unwrapped"
      "steamdeck-hw-theme"
    ]
    || _cuda.lib.allowUnfreeCudaPredicate pkg
  );
  android_sdk.accept_license = true;
}
