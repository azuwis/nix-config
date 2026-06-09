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
    network.enable = true;
    network.ssh = {
      enable = true;
      port = 2222;
      authorizedKeys = config.my.keys;
      hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
    };
    systemd = {
      # Sync boot.initrd.systemd.network.config to systemd.network.config, see ../nixos/system/default.nix
      # Initrd generates temporary /etc/machine-id, produces different DUID in each stage, and get different DHCP IP
      # Setting both systemd.network.config.dhcpV4Config.ClientIdentifier and
      # boot.initrd.systemd.network.config.dhcpV4Config.ClientIdentifier to "mac" to avoid this.
      network.config = config.systemd.network.config;
      # Automatically ask for the password on SSH login
      users.root.shell = "/bin/systemd-tty-ask-password-agent";
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
  hardware.pn532.enable = true;
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
  services.evsieve.dualsense = true;
  services.scinet.enable = true;
  services.sunshine.enhance = true;
  # Have to use mangohud git HEAD version, see overlays/default.nix
  services.sunshine.mangohud = true;
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

  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp.override { cudaSupport = true; };
    modelsPreset = {
      "*" = {
        models-max = "1";
        sleep-idle-seconds = "600";
      };
      # https://unsloth.ai/docs/models/qwen3.6#mtp-qwen3.6-35b-a3b
      # https://knightli.com/en/2026/05/26/rtx-3060-llama-cpp-n-cpu-moe-local-35b/
      "qwen3.6" = {
        alias = "qwen3.6";
        # download
        hf-repo = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF";
        hf-file = "Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf"; # 22.9G
        # sampling
        temperature = "1.0";
        top-p = "0.95";
        top-k = "20";
        min-p = "0.00";
        jinja = true; # use embedded chat template
        reasoning-format = "deepseek"; # parse <think> tags
        # engine
        flash-attn = "on";
        n-gpu-layers = "99"; # all layers to GPU
        n-cpu-moe = "36"; # MoE experts on CPU (key for 12GB VRAM)
        spec-type = "draft-mtp"; # MTP speculative decoding (~65-75 t/s)
        spec-draft-n-max = "2";
        # memory
        ctx-size = "262144"; # 256K
        cache-type-k = "q8_0"; # K cache must stay >= q8_0 for Qwen (q4_0 = catastrophic)
        cache-type-v = "q8_0"; # V cache can drop to q4_0 if VRAM tight (~0.3% PPL)
        parallel = "1"; # single user, save ~700MB VRAM (no extra KV cache slots)
        no-context-shift = true; # stop at context limit instead of evicting old messages
      };
    };
  };
}
