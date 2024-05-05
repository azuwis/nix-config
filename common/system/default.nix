{
  config,
  lib,
  pkgs,
  ...
}:

{
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;
  nix.settings = {
    extra-experimental-features = [
      "flakes"
      "nix-command"
    ];
    keep-outputs = true;
    log-lines = 25;
    tarball-ttl = 43200;
    trusted-users = [
      "root"
      config.my.user
    ];
  };
  nix.package = pkgs.nix;
  programs.zsh.enable = true;
  time.timeZone = "Asia/Shanghai";
}
