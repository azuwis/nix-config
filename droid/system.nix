{ pkgs, config, ... }:

{
  environment.etcBackupExtension = ".bak";
  nix.extraConfig = ''
    keep-env-derivations = true
    keep-outputs = true
    tarball-ttl = 43200
  '';
  nixpkgs.overlays = import ../overlays.nix;
  system.stateVersion = "21.05";
  time.timeZone = "Asia/Shanghai";
  user.shell = "${pkgs.zsh}/bin/zsh";
}
