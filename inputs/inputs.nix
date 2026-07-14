{
  agenix = {
    url = "https://github.com/ryantm/agenix";
  };
  devshell = {
    url = "https://github.com/numtide/devshell";
  };
  disko = {
    url = "https://github.com/nix-community/disko";
    ref = "refs/tags/latest";
  };
  homebrew-cask = {
    url = "https://github.com/Homebrew/homebrew-cask";
  };
  jovian-nixos = {
    url = "https://github.com/Jovian-Experiments/Jovian-NixOS";
    rev = "8f97d1dee8c0971b01cd6b17ccf913e8bb70f5d5"; # last version compatible with nixos-26.05
  };
  my = {
    url = "ssh://nuc/~/repo/my";
  };
  nix-darwin = {
    url = "https://github.com/nix-darwin/nix-darwin";
    ref = "nix-darwin-26.05";
  };
  nix-homebrew = {
    url = "https://github.com/zhaofengli/nix-homebrew";
  };
  nix-index-database = {
    url = "https://github.com/azuwis/nix-index-database";
  };
  nix-on-droid = {
    url = "https://github.com/nix-community/nix-on-droid";
  };
  nix-openwrt-imagebuilder = {
    url = "https://github.com/astro/nix-openwrt-imagebuilder";
    freeze = true;
  };
  nixos-wsl = {
    url = "https://github.com/nix-community/NixOS-WSL";
  };
  nixpkgs = {
    url = "https://github.com/NixOS/nixpkgs";
    ref = "nixos-26.05";
  };
}
