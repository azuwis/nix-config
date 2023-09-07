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
  my.pn532.enable = true;
  my.retroarch.enable = true;
  my.sunshine.enable = true;
  my.zramswap.enable = true;
  # hm.my.sunshine.package = pkgs.sunshine-git;

  hm.my.jslisten.enable = true;

  environment.systemPackages = with pkgs; [
    (runCommand "yuzu" { buildInputs = [ makeWrapper ]; } ''
      makeWrapper ${yuzu-ea}/bin/yuzu $out/bin/yuzu --set QT_QPA_PLATFORM xcb
    '')
  ];
}
