{
  agenix = {
    url = "https://github.com/ryantm/agenix";
    ref = "main";
  };
  devshell = {
    url = "https://github.com/numtide/devshell";
    ref = "main";
  };
  disko = {
    url = "https://github.com/nix-community/disko";
    ref = "refs/tags/latest";
  };
  homebrew-cask = {
    url = "https://github.com/Homebrew/homebrew-cask";
    ref = "main";
  };
  jovian-nixos = {
    url = "https://github.com/Jovian-Experiments/Jovian-NixOS";
    ref = "development";
  };
  my = {
    type = "git";
    url = "ssh://nuc/~/repo/my";
    ref = "master";
  };
  nix-darwin = {
    url = "https://github.com/nix-darwin/nix-darwin";
    ref = "master";
  };
  nix-homebrew = {
    url = "https://github.com/zhaofengli/nix-homebrew";
    ref = "main";
  };
  nix-index-database = {
    url = "https://github.com/azuwis/nix-index-database";
    ref = "main";
  };
  nix-on-droid = {
    url = "https://github.com/nix-community/nix-on-droid";
    ref = "master";
  };
  nix-openwrt-imagebuilder = {
    url = "https://github.com/astro/nix-openwrt-imagebuilder";
    ref = "main";
    freeze = true;
  };
  nixos-wsl = {
    url = "https://github.com/nix-community/NixOS-WSL";
    ref = "main";
  };
  nixpkgs = {
    url = "https://github.com/NixOS/nixpkgs";
    ref = "nixos-unstable";
  };
}
