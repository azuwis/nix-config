{
  config,
  lib,
  pkgs,
  ...
}:

# For ./scripts/solo-shell
{
  imports = [
    ../solo
  ];

  # Only add PATH for solo-shell, for normal `nix installation`, PATH is handle in `/etc/profile.d/nix.sh`
  environment.variables.PATH = "${config.solo.path}/bin:$PATH";

  nixpkgs.hostPlatform = if builtins ? currentSystem then builtins.currentSystem else "x86_64-linux";
}
