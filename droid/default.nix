{ config, lib, pkgs, home-manager-path, ... }:

{
  imports = [
    ../common
  ] ++ lib.my.getModules [ ./. ];

  hm.imports = lib.my.getHmModules [ ./. ];

  hm.my.zsh-ssh-agent.enable = true;

  # https://github.com/nix-community/nix-on-droid/pull/316
  home-manager.extraSpecialArgs = { lib = import (home-manager-path + "/modules/lib/stdlib-extended.nix") lib; };
}
