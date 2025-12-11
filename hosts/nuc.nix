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

  # On kernel 6.12, DualSense controller only works on first pair, will not connect after.
  # Kernel 6.17 works without problem.
  # Bluetooth adapter: 0bda:a725 Realtek Semiconductor Corp. Bluetooth Radio
  boot.kernelPackages = pkgs.linuxPackages_latest;

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

  # services.evdevhook.enable = true;
  desktop.enable = true;
  programs.dualsensectl.enable = true;
  services.hass.enable = true;
  hardware.intelGpu.enable = true;
  services.nix-builder.client.enable = true;
  # services.photoprism.enhance = true;
  programs.retroarch.enable = true;
  my.torrent.enable = true;
  # programs.uxplay.enable = true;
  programs.wayland.startup.initlock = lib.mkForce [ ];
  services.evsieve.enable = true;
  services.scinet.enable = true;
  zramSwap.enable = true;

  programs.swayidle.enable = false;

  # Niri does not have per input device setting yet, override `natural-scroll` for
  # Microsoft All-in-One Media Keyboard
  programs.niri.settings.input.mouse = [ ];
  programs.niri.extraConfig = ''
    output "HDMI-A-1" {
      mode "1920x1080@60.000"
    }
  '';

  programs.sway.extraConfig = ''
    bindsym XF86HomePage exec ~/bin/xf86homepage
    bindsym XF86Tools exec ~/bin/xf86tools
    # workaround for yambar sway module not getting updates
    exec swaymsg -t subscribe '["output"]' && sleep 5 && pkill yambar
  '';

  environment.systemPackages = with pkgs; [ moonlight-qt ];
}
