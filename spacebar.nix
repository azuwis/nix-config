{ config, pkgs, ... }:

{
  fonts.enableFontDir = true;
  fonts.fonts = [ pkgs.font-awesome ];
  launchd.user.agents.spacebar.serviceConfig = {
    StandardErrorPath = "/tmp/spacebar.log";
    StandardOutPath = "/tmp/spacebar.log";
  };
  services.spacebar.enable = true;
  services.spacebar.package = pkgs.spacebar;
  services.spacebar.config = {
    position                   = "top";
    height                     = 24;
    text_font                  = ''"Lucida Grande:Regular:12.0"'';
    icon_font                  = ''"Font Awesome 5 Free:Solid:12.0"'';
    background_color           = "0xff202020";
    foreground_color           = "0xffa8a8a8";
    power_icon_color           = "0xffcd950c";
    battery_icon_color         = "0xffd75f5f";
    dnd_icon_color             = "0xffa8a8a8";
    clock_icon_color           = "0xffa8a8a8";
    power_icon_strip           = " ";
    space_icon                 = "•";
    space_icon_strip           = "1 2 3 4 5 6 7 8 9 10";
    space_icon_color           = "0xff458588";
    clock_icon                 = "";
    dnd_icon                   = "";
    clock_format               = ''"%m/%d %R"'';
  };
  services.yabai.config.external_bar = "main:24:0";
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;
}
