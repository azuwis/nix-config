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
      # nixos/retroarch
      "libretro-genesis-plus-gx"
      # pkgs/by-name/ch/chameleon-ultra-firmware
      "nrf-command-line-tools"
      "nrfutil"
      "nrfutil-completion"
      "nrfutil-device"
      "nrfutil-nrf5sdk-tools"
      # nixos/nvidia
      "nvidia-settings"
      "nvidia-x11"
      # nixos/steam, hosts/jovian.nix
      "steam"
      "steam-jupiter-unwrapped"
      "steam-unwrapped"
      "steamdeck-hw-theme"
    ]
    # nixos/nvidia
    || _cuda.lib.allowUnfreeCudaPredicate pkg
  );
  android_sdk.accept_license = true;
}
