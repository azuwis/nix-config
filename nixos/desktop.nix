{ config, lib, pkgs, ... }:

{
  imports = [
    ./fcitx5
    ./firefox.nix
    ./theme.nix
  ];

  hm.imports = [
    ../common/firefox
    ../common/mpv
    ./fcitx5
    ./firefox.nix
    ./theme.nix
  ];

  hm.home.packages = with pkgs; [
    python3.pkgs.subfinder
    chromium
  ];

  nix.daemonCPUSchedPolicy = "idle";

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
    ];
  };

  security.rtkit.enable = lib.mkDefault config.services.pipewire.enable;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
}
