{
  config,
  lib,
  pkgs,
  ...
}:

let
  inputs = import ../inputs;
in

{
  # To make ssh accessable from LAN, run in host powershell:
  # ```
  # netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=22 connectaddress=<ip-in-wsl> connectport=22
  # New-NetFirewallRule -DisplayName "WSL OpenSSH Server" -Action Allow -Protocol TCP -LocalPort 22
  # ```

  imports = [
    ../nixos
    (inputs.nixos-wsl.outPath + "/modules")
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  # WSL does not need bootloader/networking/greetd/pipewire
  boot.loader.systemd-boot.enable = false;
  networking.firewall.enable = false;
  networking.useNetworkd = false;
  services.greetd.enable = lib.mkForce false;
  services.pipewire.enable = lib.mkForce false;

  networking.hostName = "wsl";

  wsl = {
    enable = true;
    defaultUser = config.my.user;
    startMenuLaunchers = true;
  };

  # programs.sway.extraSessionCommands = ''
  #   # workaround for XWayland refuses to start
  #   if [ -L /tmp/.X11-unix ]
  #   then
  #     sudo rm /tmp/.X11-unix
  #   fi
  # '';
  hm.wayland.windowManager.sway.config.output."*".mode = "1920x1080";

  my.desktop.enable = true;
  my.wayland.autologin = false;
}
