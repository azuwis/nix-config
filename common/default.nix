{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (import ../lib/my.nix) getModules;
  # inputs = import ../inputs;
  inputs = builtins.mapAttrs (_: p: p { inherit pkgs; }) (import ../inputs);
in

{
  imports = getModules [ ./. ];

  _module.args.inputs = inputs;

  # programs.alacritty.enable = true;
  programs.difftastic.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  # programs.emacs.enable = true;
  programs.editorconfig.enable = true;
  programs.git.enable = true;
  programs.jujutsu.enable = true;
  programs.lazyvim.ansible.enable = true;
  programs.lazyvim.bash.enable = true;
  programs.lazyvim.custom.enable = true;
  programs.lazyvim.enable = true;
  programs.lazyvim.helm.enable = true;
  programs.lazyvim.mini-files.enable = true;
  programs.lazyvim.neogit.enable = true;
  programs.lazyvim.nixd.enable = true;
  programs.lazyvim.nord.enable = true;
  programs.lazyvim.terraform.enable = true;
  # programs.lazyvim.update-nix-fetchgit.enable = true;
  # programs.lazyvim.yaml.enable = true;
  programs.less.enable = true;
  programs.nix-index.enable = true;
  programs.yazi.enable = true;
  programs.zsh.enable = true;
  programs.zsh.fzf.enable = true;
  programs.zsh.pure-prompt.enable = true;
  programs.zsh.zoxide.enable = true;
}
