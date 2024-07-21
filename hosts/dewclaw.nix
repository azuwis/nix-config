{
  openwrt.example = {
    packages = [
      "losetup"
      "mount-utils"
      "coreutils-stat"
      "htop"
    ];
    uci.retain = [
      "ucitrack"
      "firewall"
      "luci"
      "rpcd"
    ];
    uci.settings = {
      dropbear.dropbear = [
        {
          PasswordAuth = "on";
          RootPasswordAuth = "on";
          Port = 22;
        }
      ];

      network = {
        device = [
          {
            name = "br-lan";
            ports = "eth0";
            type = "bridge";
          }
        ];

        globals = [ { ula_prefix = "fd10:155d:7ef5::/48"; } ];

        interface.lan = {
          device = "br-lan";
          proto = "dhcp";
        };

        interface.loopback = {
          device = "lo";
          ipaddr = "127.0.0.1";
          netmask = "255.0.0.0";
          proto = "static";
        };
      };

      uhttpd.uhttpd.main = {
        listen_http = [
          "0.0.0.0:80"
          "[::]:80"
        ];
        lua_prefix = [ "/cgi-bin/luci=/usr/lib/lua/luci/sgi/uhttpd.lua" ];
        home = "/www";
        cgi_prefix = "/cgi-bin";
        ubus_prefix = "/ubus";
      };

      system = {
        system = [
          {
            hostname = "OpenWrt";
            timezone = "UTC";
            ttylogin = 0;
            log_size = 64;
            urandom_seed = 0;
            notes._secret = "notes";
          }
        ];

        timeserver.ntp = {
          enabled = true;
          enable_server = false;
          server = [
            "0.openwrt.pool.ntp.org"
            "1.openwrt.pool.ntp.org"
            "2.openwrt.pool.ntp.org"
            "3.openwrt.pool.ntp.org"
          ];
        };
      };
    };
  };
}
