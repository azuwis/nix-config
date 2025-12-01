{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ../darwin ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.hostName = "mbp";
  desktop.enable = true;

  environment.systemPackages = with pkgs; [
    moonlight-qt
  ];

  # For `devshells/darwin-vm-pn532.nix`
  # nix.linux-builder.enable = true;
  # Workaround `sandbox-exec: pattern serialization length <number> exceeds maximum (65535)`
  # Don't need after https://github.com/NixOS/nix/pull/12570
  # nix.settings.extra-sandbox-paths = [ builtins.storeDir ];
}
