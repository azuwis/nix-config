{ config, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.vim
  ];
  environment.variables = {
    EDITOR = "vim";
  };
}
