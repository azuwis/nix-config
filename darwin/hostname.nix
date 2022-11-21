{ config, lib, pkgs, ... }:

{
  networking.hostName = "mbp";
  system.patches = [
    (pkgs.writeText "hosts.patch" ''
      --- a/etc/hosts
      +++ b/etc/hosts
      @@ -7,3 +7,4 @@
       127.0.0.1	localhost
       255.255.255.255	broadcasthost
       ::1             localhost
      +${config.networking.hostName}             localhost
    '')
  ];
}
