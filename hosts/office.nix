{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-office.nix
  ];
  boot.supportedFilesystems = [ "ntfs" ];
  # powerManagement.cpuFreqGovernor = "performance";
  networking.hostName = "office";

  my.cemu.enable = true;
  my.desktop.enable = true;
  my.dualsensectl.enable = true;
  my.nvidia.enable = lib.mkDefault true;
  my.intelGpu.enable = true;
  my.libvirtd.enable = true;
  my.nix-builder.enable = true;
  my.pn532.enable = true;
  my.retroarch.enable = true;
  my.steam.enable = true;
  my.steam.nvidia-offload = true;
  my.steam.gamescope-intel-fix = true;
  programs.steam.gamescopeSession.args = [ "--fullscreen" "--output-width" "1920" "--output-height" "1080" ];
  my.sunshine.enable = true;
  my.zramswap.enable = true;
  # hm.my.sunshine.package = pkgs.sunshine-git;

  specialisation.vfio.configuration = {
    system.nixos.tags = [ "vfio" ];
    my.nvidia.enable = false;
    my.vfio = {
      enable = true;
      platform = "intel";
      vfioIds = [ "10de:1c04" "10de:10f1" ];
    };
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
