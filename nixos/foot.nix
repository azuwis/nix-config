{ config, lib, pkgs, ... }:

{
  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        font = lib.mkDefault "monospace:pixelsize=20";
        include = "${pkgs.fetchurl {
          url = "https://codeberg.org/dnkl/foot/raw/commit/a1796ba5cd1cc7b6ef03021d7db57503e445b5dd/themes/nord";
          sha256 = "sha256-YBoRdklYm2nK9xdypxNZFTloJ3xhKH0d4MvykGUP3i0=";
        }}";
      };
    };
  };

  wayland.windowManager.sway.config.terminal = "footclient";

  # hack to avoid sd-switch restart foot service
  systemd.user.services.foot.Service.ExecStart = lib.mkForce "/etc/profiles/per-user/%u/bin/foot --server --log-level=error";
}
