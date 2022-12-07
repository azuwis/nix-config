{ config, lib, pkgs, ... }:

{
  nix.settings = {
    auto-optimise-store = lib.mkDefault true;
    extra-experimental-features = [ "flakes" "nix-command" ];
    keep-outputs = true;
    tarball-ttl = 43200;
  };
  nix.generateNixPathFromInputs = true;
  nix.generateRegistryFromInputs = true;
  nix.linkInputs = true;
  nix.package = pkgs.nix;
  programs.zsh.enable = true;
  time.timeZone = "Asia/Shanghai";
}
