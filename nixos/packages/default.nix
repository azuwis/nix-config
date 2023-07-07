{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (writeScriptBin "bs" ''
      #!${runtimeShell}
      if [ "$1" = "u" ]
      then
        args=(--recreate-lock-file)
      else
        args=("$@")
      fi
      # --use-remote-sudo is needed, see https://github.com/NixOS/nixpkgs/issues/169193
      nixos-rebuild --use-remote-sudo switch --flake '/etc/nixos' ''${args[@]}
    '')
    compsize
    dnsutils
    efibootmgr
    inetutils
    iotop-c
    netproc
    nixos-option
    pciutils
    tcpdump
    usbutils
  ];
}
