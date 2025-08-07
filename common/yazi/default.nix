{
  config,
  lib,
  pkgs,
  ...
}:

let
  inputs = import ../../inputs;
  nixpkgs = inputs.nixpkgs.outPath;
  modulesPath = nixpkgs + "/nixos/modules/";
in

{
  imports = builtins.map (path: modulesPath + path) [
    "misc/meta.nix"
    "programs/yazi.nix"
  ];

  programs.yazi.settings = {
    yazi = {
      mgr.ratio = [
        1
        3
        4
      ];
      preview = {
        cache_dir = "~/.cache/yazi";
        max_height = 1200;
        max_width = 800;
      };
    };
  };
}
