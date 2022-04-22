{ config, lib, pkgs, inputs, ... }:

{
  # To make ssh accessable from LAN, run in host powershell:
  # ```
  # netsh interface portproxy add v4tov6 listenport=22 listenaddress=0.0.0.0 connectport=22 connectaddress=::1
  # New-NetFirewallRule -DisplayName "WSL OpenSSH Server" -Action Allow -Protocol TCP -LocalPort 22
  # ```

  imports = [ inputs.wsl.nixosModules.wsl ];

  # WSL does not need bootloader/networking/greetd/pipewire
  boot.loader.systemd-boot.enable = false;
  networking.firewall.enable = false;
  networking.useNetworkd = false;
  services.greetd.enable = lib.mkForce false;
  services.pipewire.enable = lib.mkForce false;

  wsl = {
    enable = true;
    automountPath = "/mnt";
    defaultUser = config.my.user;
    startMenuLaunchers = true;
    wslConf.network.hostname = "wsl";
  };

  hm.wayland.windowManager.sway.config.output."*".mode = "1920x1080";
}
