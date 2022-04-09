{ config, lib, pkgs, ... }:

let
  js = pkgs.fetchurl {
    url = "https://github.com/kalkih/mini-media-player/releases/download/v1.16.2/mini-media-player-bundle.js";
    sha256 = "sha256-WjxoioDgRcOFd1oZBeOKa5WBjbGxJkUThskZjH2FwB4=";
  };
in

{
  services.nginx.virtualHosts.hass = {
    locations."= /local/mini-media-player-bundle.js" = {
      alias = js;
    };
  };

  services.home-assistant.config.lovelace.resources = [{
    url = "/local/mini-media-player-bundle.js?v=${builtins.hashFile "md5" js}";
    type = "module";
  }];
}
