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
  # my.nvidia.enable = true;
  my.intelGpu.enable = true;
  my.pn532.enable = true;
  my.retroarch.enable = true;
  my.sunshine.enable = true;
  my.vfio = {
    enable = lib.mkDefault true;
    platform = "intel";
    vfioIds = [ "10de:1c04" "10de:10f1" ];
  };
  my.zramswap.enable = true;
  # hm.my.sunshine.package = pkgs.sunshine-git;

  specialisation.nvidia.configuration = {
    system.nixos.tags = [ "nvidia" ];
    my.nvidia.enable = true;
    my.vfio.enable = false;
  };

  hm.my.jslisten.enable = true;

  environment.systemPackages = with pkgs; [
    (runCommand "yuzu" { buildInputs = [ makeWrapper ]; } ''
      makeWrapper ${yuzu-ea}/bin/yuzu $out/bin/yuzu --set QT_QPA_PLATFORM xcb
    '')
  ];
  # Fix yuzu fullscreen framerate
  hm.wayland.windowManager.sway.config.output.HDMI-A-1.max_render_time = "10";
}
