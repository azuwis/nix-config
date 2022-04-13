{ config, lib, pkgs, ...}:

{
  imports = [
    ./fcitx5
    ./fonts.nix
    ./sway.nix
  ];

  hm.imports = [
    ../common/mpv.nix
    ./fcitx5
    ./sway.nix
  ];

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
    pulse.enable = true;
  };
}
