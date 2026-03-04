{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.vlmcsd;
in

{
  options.vlmcsd = {
    enable = lib.mkEnableOption "vlmcsd";
  };

  config = lib.mkIf cfg.enable {
    builder.packages = [ "vlmcsd" ];

    files.file."etc/uci-defaults/96-vlmcsd".text = ''
      hostname=$(uci -q get 'system.@system[0].hostname')
      domain=$(uci -q get 'dhcp.@dnsmasq[0].domain')
      uci batch <<EOF
      set dhcp.vlmcsd=srvhost
      set dhcp.vlmcsd.srv='_vlmcs._tcp.$domain'
      set dhcp.vlmcsd.target='$hostname.$domain'
      set dhcp.vlmcsd.port='1688'
      set dhcp.vlmcsd.class='0'
      set dhcp.vlmcsd.weight='100'
      commit
      EOF
    '';

    sdk.enable = true;
    sdk.builds = [
      {
        downloadHash = "sha256-1GdnxoH183ETtYLjrirrwbcUAKfptCQwv++I2Bly5ok=";
        packages = [ "vlmcsd" ];
      }
    ];
  };
}
