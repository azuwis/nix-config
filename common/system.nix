{ config, lib, pkgs, ... }:

{
  nix.allowedUsers = [ "${config.my.user}" ];
  nix.extraOptions = ''
    keep-outputs = true
    experimental-features = flakes nix-command
    tarball-ttl = 43200
  '';
  nix.package = pkgs.nixUnstable;
  nixpkgs.overlays = import ../overlays.nix;
  programs.zsh.enable = true;
  time.timeZone = "Asia/Shanghai";
}
