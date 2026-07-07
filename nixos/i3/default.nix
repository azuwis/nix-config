{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.programs.i3;
in
{
  options.programs.i3 = {
    enable = mkEnableOption "i3";
    autologin = mkEnableOption "autologin" // {
      default = true;
    };
    initlock = mkEnableOption "initlock";
    xdgAutostart = mkEnableOption "xdgAutostart";
    extraConfig = mkOption {
      type = types.lines;
      default = "";
    };
    terminal = mkOption {
      type = types.str;
      default = "wezterm";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    ({
      programs.dconf.enable = true;

      services.xserver = {
        enable = true;
        autoRepeatDelay = 300;
        autoRepeatInterval = 33;
        extraDisplaySettings = "Virtual 1920 1080";
        displayManager.startx.enable = true;
      };

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.greetd.greetd}/bin/agreety --cmd 'systemd-cat --identifier=startx startx'";
          };
        };
      };

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
      security.rtkit.enable = lib.mkDefault config.services.pipewire.enable;

      environment.systemPackages = with pkgs; [
        (runCommandLocal "rofi-dmenu" { } ''
          mkdir -p $out/bin
          ln -s ${rofi}/bin/rofi $out/bin/dmenu
        '')
        hsetroot
        i3lock
        pulsemixer
        rofi
        wezterm
        xdotool
      ];

      environment.etc."i3/config".source = pkgs.replaceVars ./config {
        inherit (cfg) extraConfig terminal;
      };

      programs.i3.extraConfig =
        lib.optionalString cfg.initlock ''
          exec i3lock --nofork --ignore-empty-password --color=2e3440
        ''
        + lib.optionalString cfg.xdgAutostart ''
          exec systemctl --user start xdg-autostart-if-no-desktop-manager.target
        '';

      services.xserver.windowManager.i3.enable = true;
    })

    (mkIf cfg.autologin {
      # to start initial_session again, run `/run/greetd.run; systemctl restart greetd`
      services.greetd.settings.initial_session = {
        command = "systemd-cat --identifier=startx startx";
        user = config.my.user;
      };
    })

    (mkIf cfg.xdgAutostart {
      services.xserver.desktopManager.runXdgAutostartIfNone = true;
    })
  ]);
}
