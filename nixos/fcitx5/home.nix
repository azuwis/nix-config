{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.fcitx5;

  fcitx5-nord = pkgs.fetchFromGitHub rec {
    name = "${repo}-${rev}";
    owner = "tonyfettes";
    repo = "fcitx5-nord";
    rev = "bdaa8fb723b8d0b22f237c9a60195c5f9c9d74d1";
    hash = "sha256-qVo/0ivZ5gfUP17G29CAW0MrRFUO0KN1ADl1I/rvchE=";
  };

in
{
  options.my.fcitx5 = {
    enable = mkEnableOption "fcitx5";
  };

  config = mkIf cfg.enable {
    # home.activation.fcitx5 = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #   ${fcitx5}/bin/fcitx5-remote -r || true
    # '';
    xdg.configFile.fcitx5.source = ./config;
    xdg.dataFile."fcitx5/themes".source = fcitx5-nord;
    wayland.windowManager.sway.config.startup = [{ command = "fcitx5"; }];
    xsession.windowManager.i3.config.startup = [{ command = "fcitx5"; }];
  };
}
