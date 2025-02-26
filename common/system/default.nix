{
  config,
  lib,
  pkgs,
  ...
}:

{
  # nix.gc = {
  #   automatic = true;
  #   options = "--delete-older-than 30d";
  # };
  nix.optimise.automatic = lib.mkDefault true;
  nix.settings = {
    # https://docs.lix.systems/manual/lix/stable/release-notes/rl-2.91.html
    # Reject options set by flakes by default
    accept-flake-config = false;
    extra-experimental-features = [
      "flakes"
      "nix-command"
    ];
    flake-registry = "";
    keep-outputs = true;
    log-lines = 25;
    tarball-ttl = 43200;
    trusted-users = [
      "root"
      config.my.user
    ];
  };
  # https://github.com/NixOS/nix/pull/11992
  nix.package = pkgs.nixVersions.nix_2_26;
  programs.zsh.enable = true;
  time.timeZone = "Asia/Shanghai";
}
