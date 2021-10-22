{ config, lib, pkgs, ... }:

{
  home.file."Applications/Home Manager Apps".source =
    let
      apps = pkgs.buildEnv {
        name = "home-manager-applications";
        paths = config.home.packages;
        pathsToLink = "/Applications";
      };
    in
      "${apps}/Applications";
}
