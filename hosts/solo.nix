{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../solo
  ];

  # Only add shell to systemPackages for solo, prevent infinite recursion with solo-shell
  environment.systemPackages = [ (lib.hiPrio config.solo.shell) ];

  nixpkgs.hostPlatform = if builtins ? currentSystem then builtins.currentSystem else "x86_64-linux";
}
