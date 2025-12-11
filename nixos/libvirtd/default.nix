{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.virtualisation.libvirtd;
in
{
  options.virtualisation.libvirtd = {
    enhance = lib.mkEnableOption "and enhance libvirtd";
  };

  config = lib.mkIf cfg.enhance {
    environment.systemPackages = with pkgs; [ virt-manager ];

    virtualisation.libvirtd.enable = true;
    virtualisation.libvirtd.qemu = {
      package = pkgs.qemu_kvm;
    };

    users.users.${config.my.user}.extraGroups = [ "libvirtd" ];
  };
}
