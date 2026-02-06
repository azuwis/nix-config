{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.termfilechooser;
in

{
  options.programs.termfilechooser = {
    enable = lib.mkEnableOption "programs.termfilechooser";
  };

  config = lib.mkIf cfg.enable {
    programs.firefox.settings."widget.use-xdg-desktop-portal.file-picker" = 1; # 0 - Never, 1 - Always, 2 - Auto

    # Normally should use this config:
    # environment.etc."xdg/xdg-desktop-portal-termfilechooser/config".text = ''
    #   [filechooser]
    #   env=TERMCMD='...'
    # '';
    # But unfortunately xdg-desktop-portal-termfilechooser look for the wrong config file in NixOS:
    # /nix/store/...-xdg-desktop-portal-termfilechooser-.../etc/xdg/xdg-desktop-portal-termfilechooser/config
    # Use systemd overrides to set TERMCMD instead:
    systemd.user.services.xdg-desktop-portal-termfilechooser = {
      environment.TERMCMD =
        let
          inherit (config.programs.wayland) terminal;
          termcmd =
            if terminal == "foot" || terminal == "footclient" then
              "${terminal} --app-id tmenu --window-size-chars 145x38"
            else
              terminal;
        in
        termcmd;
      # Remove `Environment="PATH=..."`, so PATH imported by `systemctl --user import-environment` will be used
      path = lib.mkForce [ ];
    };

    xdg.portal = {
      config.common."org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
      # niri NixOS module set to gtk, need to override
      config.niri."org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
      extraPortals = [ pkgs.xdg-desktop-portal-termfilechooser ];
    };
  };
}
