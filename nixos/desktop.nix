{ config, lib, pkgs, ... }:

{
  imports = [
    ./fcitx5
    ./firefox.nix
    ./sway.nix
    ./theme.nix
  ];

  hm.imports = [
    ../common/firefox
    ../common/mpv.nix
    ./fcitx5
    ./firefox.nix
    ./sway.nix
    ./theme.nix
  ];

  nix.daemonCPUSchedPolicy = "idle";

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
    ];
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.greetd}/bin/agreety --cmd sway";
      };
    };
  };

  security.rtkit.enable = lib.mkDefault config.services.pipewire.enable;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
}
