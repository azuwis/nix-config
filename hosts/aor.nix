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

  # boot.kernelPackages = pkgs.linuxPackagesFor (
  #   pkgs.linuxKernel.kernels.linux_6_12.override {
  #     argsOverride = rec {
  #       version = "6.12.46";
  #       src = pkgs.fetchurl {
  #         url = "mirror://kernel/linux/kernel/v${lib.versions.major version}.x/linux-${version}.tar.xz";
  #         hash = "sha256:0gjp2jqw9ip8j5i97bg2xvdy6r5sqzvia16qqlisrji4sf176pif";
  #       };
  #       modDirVersion = version;
  #     };
  #   }
  # );

  boot.loader.limine.enable = true;
  boot.loader.limine.secureBoot.enable = true;

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

  boot.extraModulePackages = [ config.boot.kernelPackages.r8125 ];
  boot.supportedFilesystems = [ "ntfs" ];
  # powerManagement.cpuFreqGovernor = "performance";
  networking.hostName = "aor";

  programs.cemu.enable = true;
  desktop.enable = true;
  programs.dualsensectl.enable = true;
  hardware.nvidia.enhance = lib.mkDefault true;
  hardware.nvidia.open = true;
  virtualisation.libvirtd.enhance = true;
  services.nix-builder.enable = true;
  my.pn532.enable = true;
  programs.retroarch.enable = true;
  programs.wayland.scale = 2;
  programs.steam.enhance = true;
  # programs.steam.gamescope-intel-fix = true;
  # programs.steam.gamescope-git = true;
  # programs.steam.nvidia-offload = true;
  programs.steam.gamescopeSession.args = [
    "--fullscreen"
    "--output-width"
    "1920"
    "--output-height"
    "1080"
  ];
  # programs.steam.remotePlay.openFirewall = true;
  services.evsieve.enable = true;
  services.scinet.enable = true;
  services.sunshine.enable = true;
  # After update to 25.11, sunshine crash when using AMD vaapi encoder, may related to mesa bump
  # https://github.com/LizardByte/Sunshine/issues/4358
  # services.sunshine.settings.adapter_name = "/dev/dri/by-path/pci-0000:11:00.0-render";
  services.sunshine.cudaSupport = true;
  services.sunshine.settings.encoder = "nvenc";
  zramSwap.enable = true;

  # Eval time will be multiplied by specialisations count
  # specialisation.vfio.configuration = {
  #   system.nixos.tags = [ "vfio" ];
  #   hardware.nvidia.enhance = false;
  #   hardware.vfio = {
  #     enable = true;
  #     platform = "amd";
  #     vfioIds = [ "10de:2f04" "10de:2f80" ]; # lspci -nn | grep NVIDIA
  #   };
  # };

  environment.systemPackages = with pkgs; [
    eden
    nix-search
  ];
  # Fix yuzu fullscreen framerate
  # programs.sway.extraConfig = ''
  #   output * max_render_time 10
  # '';

  users.users.steam = {
    isNormalUser = true;
    uid = 3000;
    openssh.authorizedKeys.keys = config.my.keys;
  };

  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };
}
