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

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
}
