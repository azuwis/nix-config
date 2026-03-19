let
  git = url: args: (args // { type = "git"; } // { inherit url; });
  archive = url: args: (args // { type = "archive"; } // { inherit url; });
  github = url: args: archive ("https://github.com/" + url) args;
  codeberg = url: args: archive ("https://codeberg.org/" + url) args;
in

{
  agenix = github "ryantm/agenix" { };
  devshell = github "numtide/devshell" { };
  disko = github "nix-community/disko" { ref = "refs/tags/latest"; };
  homebrew-cask = github "Homebrew/homebrew-cask" { };
  jovian-nixos = github "Jovian-Experiments/Jovian-NixOS" { };
  my = git "ssh://nuc/~/repo/my" { };
  nix-darwin = github "nix-darwin/nix-darwin" { ref = "nix-darwin-25.11"; };
  nix-homebrew = github "zhaofengli/nix-homebrew" { };
  nix-index-database = github "azuwis/nix-index-database" { };
  nix-on-droid = github "nix-community/nix-on-droid" { };
  nix-openwrt-imagebuilder = github "astro/nix-openwrt-imagebuilder" { freeze = true; };
  nixos-wsl = github "nix-community/NixOS-WSL" { };
  nixpkgs = github "NixOS/nixpkgs" { ref = "nixos-25.11"; };
}
