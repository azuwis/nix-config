{
  config,
  lib,
  pkgs,
  ...
}:

let
  inputs = import ../inputs;
in

{
  imports = [
    ./difftastic
    ./git
    ./jujutsu
    ./lazyvim
    ./less
    ./mpv
    ./my
    ./packages
    ./yazi
    ./zsh
  ];

  _module.args.inputs = inputs;

  programs.difftastic.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.git.enable = true;
  programs.yazi.enable = true;
  wrappers.jujutsu.enable = true;

  wrappers.lazyvim.enable = true;
  wrappers.lazyvim.ansible.enable = true;
  wrappers.lazyvim.bash.enable = true;
  wrappers.lazyvim.custom.enable = true;
  wrappers.lazyvim.helm.enable = true;
  wrappers.lazyvim.mini-files.enable = true;
  wrappers.lazyvim.neogit.enable = true;
  wrappers.lazyvim.nix.enable = true;
  wrappers.lazyvim.nord.enable = true;
  wrappers.lazyvim.terraform.enable = true;
  # wrappers.lazyvim.yaml.enable = true;
  # wrappers.lazyvim.update-nix-fetchgit.enable = true;

  programs.zsh.enable = true;
  programs.zsh.fzf.enable = true;
  programs.zsh.pure-prompt.enable = true;
  programs.zsh.zoxide.enable = true;
}
