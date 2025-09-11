{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./hardware-hyperv.nix ];

  # Grub
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    copyKernels = true;
    efiSupport = true;
    mirroredBoots = [
      {
        devices = [ "nodev" ];
        path = "/boot1";
      }
      {
        devices = [ "nodev" ];
        path = "/boot2";
      }
      {
        devices = [ "nodev" ];
        path = "/boot3";
      }
    ];
  };
  fileSystems."/boot1" = {
    options = [
      "defaults"
      "nofail"
      "x-systemd.device-timeout=5s"
    ];
  };
  fileSystems."/boot2" = {
    options = [
      "defaults"
      "nofail"
      "x-systemd.device-timeout=5s"
    ];
  };
  fileSystems."/boot3" = {
    options = [
      "defaults"
      "nofail"
      "x-systemd.device-timeout=5s"
    ];
  };

  networking.hostName = "hyperv";

  # ZFS
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "65e3452b";
  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot.enable = true;

  # conflict with hyperv_drm, needed by sway
  boot.blacklistedKernelModules = [ "hyperv_fb" ];

  # follow OS keyboard, so capslock/ctrl will NOT be swapped back
  services.udev.extraHwdb = lib.mkForce "";

  my.sway.extraConfig = ''
    output * mode 1600x900
  '';

  my.desktop.enable = true;
  my.zramswap.enable = true;
}
