{ url, sha256, name ? builtins.baseNameOf url, cfg ? { } }: { config, lib, pkgs, ... }:

let
  js = pkgs.fetchurl {
    inherit url sha256;
  };
in

{
  config = lib.mkIf config.my.hass.enable (lib.mkMerge ([
    {
      services.nginx.virtualHosts.hass.locations."= /local/${name}".alias = js;
      services.home-assistant.config.lovelace.resources = [{
        url = "/local/${name}?v=${builtins.hashFile "md5" js}";
        type = "module";
      }];
    }
    cfg
  ]));
}
