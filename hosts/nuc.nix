{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../nixos
    ./hardware-nuc.nix
  ];

  powerManagement.cpuFreqGovernor = "schedutil";
  fileSystems."/".options = [ "compress-force=zstd" ];
  fileSystems."/srv".options = [ "compress=zstd" ];
  networking.hostName = "nuc";
  # networking.useDHCP = false;
  # networking.vlans.vlan1.id = 1;
  # networking.vlans.vlan1.interface = "eno1";
  # networking.interfaces.vlan1.useDHCP = true;
  # networking.vlans.vlan5.id = 5;
  # networking.vlans.vlan5.interface = "eno1";
  # networking.interfaces.vlan5.ipv4 = {
  #   addresses = [{ address = "192.168.20.250"; prefixLength = 24; }];
  #   routes = [{ address = "240.0.0.0"; prefixLength = 4; }];
  # };
  # services.beesd.filesystems = {
  #   nixos = {
  #     spec = "/";
  #     hashTableSizeMB = 128;
  #     verbosity = "info";
  #     extraOptions = [
  #       "--loadavg-target"
  #       "2.0"
  #     ];
  #   };
  # };

  # my.evdevhook.enable = true;
  my.desktop.enable = true;
  my.dualsensectl.enable = true;
  my.hass.enable = true;
  my.intelGpu.enable = true;
  my.nix-builder-client.enable = true;
  # my.photoprism.enable = true;
  my.retroarch.enable = true;
  my.torrent.enable = true;
  my.uxplay.enable = true;
  my.wayland.initlock = false;
  my.zramswap.enable = true;

  hm.my.jslisten.enable = true;
  hm.my.swayidle.enable = false;

  hm.wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
    XF86HomePage = "exec ~/bin/xf86homepage";
    XF86Tools = "exec ~/bin/xf86tools";
  };

  # workaround for yambar sway module not getting updates
  hm.wayland.windowManager.sway.config.startup = [
    { command = ''swaymsg -t subscribe '["output"]' && sleep 5 && pkill yambar''; }
  ];

  environment.systemPackages = with pkgs; [ moonlight-qt ];
}
