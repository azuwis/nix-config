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
  nix.package = pkgs.nix;
  time.timeZone = "Asia/Shanghai";
}
