{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.scinet;
in

{
  options.services.scinet = {
    enable = lib.mkEnableOption "services.scinet";
    package = lib.mkPackageOption pkgs "shadowsocks-rust" { };
  };

  config = lib.mkIf cfg.enable {
    services.smartdns.enhance = true;

    age.secrets."shadowsocks-rust-redir.json".file = "${inputs.my.outPath}/shadowsocks-rust-redir.json";
    systemd.services.shadowsocks-rust =
      let
        # https://en.wikipedia.org/wiki/Reserved_IP_addresses
        setupNftables = pkgs.runCommand "shadowsocks-rust-setup-nftables" { preferLocalBuild = true; } ''
          cat <<EOF >$out
          #! ${pkgs.nftables}/bin/nft -f
          include "${clearNftables}"
          table ip shadowsocks-rust {
            set local {
              type ipv4_addr
              flags interval
              auto-merge
              elements = {
                0.0.0.0/8,
                10.0.0.0/8,
                100.64.0.0/10,
                127.0.0.0/8,
                169.254.0.0/16,
                172.16.0.0/12,
                192.0.0.0/24,
                192.0.2.0/24,
                192.88.99.0/24,
                192.168.0.0/16,
                198.18.0.0/15,
                198.51.100.0/24,
                203.0.113.0/24,
                224.0.0.0/4,
                240.0.0.0/4,
                255.255.255.255/32,
          EOF
                tr '\n' , <${pkgs.chnroutes2} >>$out
          cat <<EOF >>$out
              }
            }
            chain tcp_redir {
              type nat hook output priority filter; policy accept;
              oif lo accept
              ip daddr @local accept
              tcp dport { 20-1023, 3000, 5222, 5228, 8000, 32200 } dnat to 127.0.0.1:7071
            }
            chain udp_mark {
              type route hook output priority mangle; policy accept;
              ip daddr @local accept
              udp dport { 53, 443 } meta mark set 0x5358
            }
            chain udp_redir {
              type filter hook prerouting priority mangle; policy accept;
              ip daddr @local accept
              udp dport { 53, 443 } meta mark 0x5358 tproxy to 127.0.0.1:7071
            }
          }
          EOF
          chmod +x $out
        '';
        clearNftables = pkgs.writeScript "shadowsocks-rust-clear-nftables" ''
          #! ${pkgs.nftables}/bin/nft -f
          table ip shadowsocks-rust
          delete table ip shadowsocks-rust
        '';
        setupIpRule = pkgs.writeScript "shadowsocks-rust-setup-iprule" ''
          #! ${pkgs.iproute2}/bin/ip -batch
          rule add fwmark 0x5358 lookup 5358
          route add local 0.0.0.0/0 dev lo table 5358
        '';
        clearIpRule = pkgs.writeScript "shadowsocks-rust-clear-iprule" ''
          #! ${pkgs.iproute2}/bin/ip -batch
          rule delete fwmark 0x5358 lookup 5358
          route delete local 0.0.0.0/0 dev lo table 5358
        '';
      in
      {
        description = "shadowsocks-rust Daemon";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        restartTriggers = [ config.age.secrets."shadowsocks-rust-redir.json".file ];
        serviceConfig = {
          DynamicUser = true;
          # Needed for udp tproxy
          CapabilityBoundingSet = [ "CAP_NET_RAW" ];
          AmbientCapabilities = [ "CAP_NET_RAW" ];
          LoadCredential = "config.json:${config.age.secrets."shadowsocks-rust-redir.json".path}";
          ExecStart = "${lib.getBin cfg.package}/bin/sslocal --config \${CREDENTIALS_DIRECTORY}/config.json";
          # `+` run commands as root
          ExecStartPost = [
            "+${setupIpRule}"
            "+${setupNftables}"
          ];
          ExecStopPost = [
            "+${clearIpRule}"
            "+${clearNftables}"
          ];
        };
      };
  };
}
