{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.hass;

  module = with pkgs; stdenv.mkDerivation (finalAttrs: {
    pname = "simple-thermostat";
    version = "2.5.0";
    src = fetchurl {
      url = "https://github.com/nervetattoo/simple-thermostat/releases/download/v${finalAttrs.version}/simple-thermostat.js";
      hash = "sha256-mC7/6MsVrLkNgkls6VDAaCgHTzw5noYV+VOeCy6y+Xo=";
    };
    dontUnpack = true;
    installPhase = ''
      mkdir $out
      cp $src $out/simple-thermostat.js
    '';
    passthru.entrypoint = "simple-thermostat.js";
  });
in
{
  options.my.hass = {
    simple-thermostat = mkEnableOption "hass" // { default = true; };
  };

  config = mkIf (cfg.enable && cfg.simple-thermostat) {
    services.home-assistant.customLovelaceModules = [ module ];
  };
}
