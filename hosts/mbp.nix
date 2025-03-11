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
  my.desktop.enable = true;

  # For `flakes/darwin-vm.nix`
  # nix.linux-builder.enable = true;
  # Workaround `sandbox-exec: pattern serialization length <number> exceeds maximum (65535)`
  # nix.settings.extra-sandbox-paths = [ "/nix/store" ];
}
