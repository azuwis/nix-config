{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.hass;

  component = pkgs.fetchFromGitHub rec {
    name = "${repo}-${rev}";
    owner = "custom-components";
    repo = "media_player.braviatv_psk";
    rev = "0.4.2";
    sha256 = "sha256-N1fAMk1MaS/FI4nkNYfRM+H7K/+sSrQogj+BodR5Opk=";
  };
in
{
  options.my.hass = {
    braviatv = mkEnableOption (mdDoc "braviatv") // { default = true; };
  };

  config = mkIf (cfg.enable && cfg.braviatv) {
    hass.file."custom_components/braviatv_psk".source = "${component}/custom_components/braviatv_psk";

    services.home-assistant.extraPackages = ps: [ pkgs.python3.pkgs.pysonybraviapsk ];

    services.home-assistant.config.media_player = [{
      platform = "braviatv_psk";
      name = "TV";
      host = "tvc5a360064409.lan";
      mac = "!secret braviatv_mac";
      psk = "!secret braviatv_psk";
    }];
  };
}
