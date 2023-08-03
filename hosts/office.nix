{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-office.nix
  ];
  boot.supportedFilesystems = [ "ntfs" ];
  powerManagement.cpuFreqGovernor = "schedutil";
  networking.hostName = "office";

  my.cemu.enable = true;
  my.desktop.enable = true;
  my.dualsensectl.enable = true;
  my.nvidia.enable = true;
  my.retroarch.enable = true;
  my.sunshine.enable = true;
  # hm.my.sunshine.package = pkgs.sunshine-git;

  hm.my.jslisten.enable = true;
  hm.my.jslisten.settings = {
    # L+PS
    BotW = {
      program = ''sh -c "dualsensectl trigger right feedback 5 8; cemu --fullscreen --title-id 00050000101c9300"'';
      button1 = 4;
      button2 = 10;
    };
  };

}
