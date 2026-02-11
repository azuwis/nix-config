{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.nps;

  npsCache =
    pkgs.runCommand "nps-cache"
      {
        nativeBuildInputs = [
          pkgs.nix
          pkgs.nps
          pkgs.writableTmpDirAsHomeHook
        ];
        preferLocalBuild = true;
      }
      ''
        export NIX_CONFIG="
        experimental-features = nix-command flakes
        flake-registry =
        "
        nix registry add nixpkgs path:${inputs.nixpkgs.outPath}
        NIX_PACKAGE_SEARCH_EXPERIMENTAL=true nps --refresh
        cp -r "$HOME/.nix-package-search" "$out"
      '';

  nps = pkgs.wrapper {
    package = pkgs.nps;
    env.NIX_PACKAGE_SEARCH_CACHE_FOLDER_ABSOLUTE_PATH = npsCache;
    env.NIX_PACKAGE_SEARCH_EXPERIMENTAL = "true";
  };
in

{
  options.programs.nps = {
    enable = lib.mkEnableOption "programs.nps";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ nps ];
  };
}
