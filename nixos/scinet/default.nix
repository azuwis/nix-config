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
    services.smartdns.enable = true;

    age.secrets."shadowsocks-rust-redir.json".file = "${inputs.my.outPath}/shadowsocks-rust-redir.json";
    systemd.services.shadowsocks-rust =
      let
        # https://en.wikipedia.org/wiki/Reserved_IP_addresses
        ExecStartPost = pkgs.writeScript "shadowsocks-rust-post-start" ''
          #! ${pkgs.nftables}/bin/nft -f
          include "${ExecStopPost}"
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
                ${builtins.replaceStrings [ "\n" ] [ "," ] (builtins.readFile pkgs.chnroutes2)}
              }
            }
            chain output {
              type nat hook output priority filter; policy accept;
              oif lo accept
              ip daddr @local accept
              tcp dport { 22, 53, 80, 8000, 443, 587, 873, 993, 3000, 5222, 5228, 32200 } dnat to 127.0.0.1:7071
            }
          }
        '';
        ExecStopPost = pkgs.writeScript "shadowsocks-rust-pre-stop" ''
          #! ${pkgs.nftables}/bin/nft -f
          table ip shadowsocks-rust
          delete table ip shadowsocks-rust
        '';
      in
      {
        description = "shadowsocks-rust Daemon";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          inherit ExecStartPost ExecStopPost;
          DynamicUser = true;
          CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
          AmbientCapabilities = [ "CAP_NET_ADMIN" ];
          LoadCredential = "config.json:${config.age.secrets."shadowsocks-rust-redir.json".path}";
          ExecStart = "${lib.getBin cfg.package}/bin/sslocal --config \${CREDENTIALS_DIRECTORY}/config.json";
        };
      };
  };
}
