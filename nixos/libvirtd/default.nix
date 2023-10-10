{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.libvirtd;
in
{
  options.my.libvirtd = {
    enable = mkEnableOption (mdDoc "libvirtd");
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      virt-manager
    ];

    virtualisation.libvirtd = {
      enable = true;

      qemu = {
        package = pkgs.qemu_kvm;
        ovmf.enable = true;
      };

    };

    users.users.${config.my.user}.extraGroups = [ "libvirtd" ];
  };
}
