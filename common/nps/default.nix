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
      # ref: nixpkgs/lib/path/tests/default.nix
      ''
        export NIX_CONF_DIR=$HOME/etc
        export NIX_STATE_DIR=$HOME/state
        export NIX_STORE_DIR=$HOME/store
        mkdir -p "$NIX_CONF_DIR"
        cat >"$NIX_CONF_DIR/nix.conf" <<EOF
        experimental-features = nix-command flakes
        flake-registry =
        EOF
        nix registry add nixpkgs path:${inputs.nixpkgs.outPath}
        NIX_PACKAGE_SEARCH_EXPERIMENTAL=true nps --refresh -dd
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
