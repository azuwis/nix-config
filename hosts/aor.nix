{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../nixos
    ./disk-aor.nix
    ./hardware-aor.nix
  ];

  # https://wiki.nixos.org/wiki/Remote_disk_unlocking
  # mkdir -p /etc/secrets/initrd
  # ssh-keygen -t ed25519 -N "" -f /etc/secrets/initrd/ssh_host_ed25519_key
  boot.initrd = {
    availableKernelModules = [ "r8125" ];
    network = {
      enable = true;
      udhcpc.enable = true;
      ssh = {
        enable = true;
        port = 2222;
        authorizedKeys = config.my.keys;
        hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
      };
      postCommands = ''
        # Automatically ask for the password on SSH login
        echo 'cryptsetup-askpass || echo "Unlock was successful; exiting SSH session" && exit 1' >> /root/.profile
      '';
    };
  };

  boot.extraModulePackages = [ pkgs.linuxPackages.r8125 ];
  boot.supportedFilesystems = [ "ntfs" ];
  # powerManagement.cpuFreqGovernor = "performance";
  networking.hostName = "aor";

  my.cemu.enable = true;
  my.desktop.enable = true;
  my.dualsensectl.enable = true;
  my.nvidia.enable = lib.mkDefault true;
  hardware.nvidia.open = true;
  # my.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  my.libvirtd.enable = true;
  my.nix-builder.enable = true;
  my.pn532.enable = true;
  my.retroarch.enable = true;
  my.scale = 2;
  my.steam.enable = true;
  # my.steam.gamescope-intel-fix = true;
  # my.steam.gamescope-git = true;
  # my.steam.nvidia-offload = true;
  programs.steam.gamescopeSession.args = [
    "--fullscreen"
    "--output-width"
    "1920"
    "--output-height"
    "1080"
  ];
  # programs.steam.remotePlay.openFirewall = true;
  my.sunshine.enable = true;
  # avoid vfio use another sunshine instance
  hm.my.sunshine.cudaSupport = true;
  # hm.my.sunshine.package = pkgs.sunshine-git;
  my.zramswap.enable = true;

  # Eval time will be multiplied by specialisations count
  # specialisation.vfio.configuration = {
  #   system.nixos.tags = [ "vfio" ];
  #   my.nvidia.enable = false;
  #   my.vfio = {
  #     enable = true;
  #     platform = "intel";
  #     vfioIds = [
  #       "10de:2f04"
  #       "10de:2f80"
  #     ];
  #   };
  # };

  hm.my.jslisten.enable = true;
  hm.my.scale = 2;

  environment.systemPackages = with pkgs; [
    nix-search
    torzu
  ];
  # Fix yuzu fullscreen framerate
  hm.wayland.windowManager.sway.config.output.HDMI-A-1.max_render_time = "10";

  users.users.steam = {
    isNormalUser = true;
    uid = 3000;
    openssh.authorizedKeys.keys = config.my.keys;
  };
}
