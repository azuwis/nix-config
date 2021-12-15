{ pkgs, config, ... }:

{
  build.activation.procStat = ''
    if [ ! -e "${config.build.installationDir}/proc/stat" ]; then
      $VERBOSE_ECHO "Generating fake /proc/stat"
      $DRY_RUN_CMD mkdir -p "${config.build.installationDir}/proc"
      $DRY_RUN_CMD echo "btime 0" > "${config.build.installationDir}/proc/stat"
    fi
  '';
  build.extraProotOptions = ["-b" "${config.build.installationDir}/proc/stat:/proc/stat"];
  environment.etc.zshenv.text = ''
  . "${config.build.sessionInit}/etc/profile.d/nix-on-droid-session-init.sh"
  set +u
  '';
  environment.etcBackupExtension = ".bak";
  nix.extraConfig = ''
    experimental-features = flakes nix-command
    keep-outputs = true
    tarball-ttl = 43200
  '';
  nix.package = pkgs.nix_2_4;
  nixpkgs.overlays = import ../overlays.nix;
  system.stateVersion = "21.11";
  time.timeZone = "Asia/Shanghai";
  user.shell = "${pkgs.zsh}/bin/zsh";
}
