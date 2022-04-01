{ config, lib, pkgs, ...}:

{
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

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      rofi-wayland
    ];
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
    '';
  };

  environment.systemPackages = with pkgs; [
    firefox-wayland
    kitty
    pulsemixer
  ];
}