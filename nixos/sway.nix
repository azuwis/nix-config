{ config, lib, pkgs, ...}:

if builtins.hasAttr "hm" lib then

{
  home.packages = with pkgs; [
    firefox-wayland
    foot
    pulsemixer
  ];

  wayland.windowManager.sway = {
    enable = true;
    package = null;
    systemdIntegration = false;
    config = {
      terminal = "foot";
    };
  };
}

else

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
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
    '';
  };

  fonts = {
    fonts = with pkgs; [
      fira
      jetbrains-mono-nerdfont
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      poly
    ];
    fontconfig.defaultFonts = {
      sansSerif = [
        "Fira Sans"
        "Noto Sans CJK SC"
      ];
      serif = [
        "Poly"
        "Noto Serif CJK SC"
      ];
      monospace = [
        "JetBrainsMono Nerd Font"
        "Noto Sans Mono CJK SC"
      ];
    };
  };
}
