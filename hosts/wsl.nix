{ inputs, config, lib, pkgs, ... }:

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

  networking.hostName = "wsl";

  wsl = {
    enable = true;
    defaultUser = config.my.user;
    # need to disable when generating install/tarball, https://github.com/nix-community/NixOS-WSL/pull/243
    nativeSystemd = true;
    startMenuLaunchers = true;
  };

  # programs.sway.extraSessionCommands = ''
  #   # workaround for XWayland refuces to start
  #   if [ -L /tmp/.X11-unix ]
  #   then
  #     sudo rm /tmp/.X11-unix
  #   fi
  # '';
  hm.wayland.windowManager.sway.config.output."*".mode = "1920x1080";

  my.desktop.enable = true;
  my.sway.autologin = false;
}
