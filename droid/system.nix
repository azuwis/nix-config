{ pkgs, config, ... }:

{
  environment.etcBackupExtension = ".bak";
  nix.extraConfig = ''
    experimental-features = flakes nix-command
    keep-outputs = true
    tarball-ttl = 43200
  '';
  nix.package = pkgs.nix_2_4;
  system.stateVersion = "21.11";
  time.timeZone = "Asia/Shanghai";
  user.shell = "${pkgs.zsh}/bin/zsh";
}
