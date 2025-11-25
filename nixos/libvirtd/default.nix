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
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ virt-manager ];

    virtualisation.libvirtd.qemu = {
      package = pkgs.qemu_kvm;
      ovmf.enable = true;
    };

    users.users.${config.my.user}.extraGroups = [ "libvirtd" ];
  };
}
