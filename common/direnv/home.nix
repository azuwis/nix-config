{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.direnv;
in
{
  options.my.direnv = {
    enable = mkEnableOption "direnv";
  };

  config = mkIf cfg.enable {
    programs.direnv.enable = true;
    # programs.direnv.stdlib = ''
    #   : ''${XDG_CACHE_HOME:=$HOME/.cache}
    #   declare -A direnv_layout_dirs
    #   direnv_layout_dir() {
    #     echo "''${direnv_layout_dirs[$PWD]:=$(
    #       echo -n "$XDG_CACHE_HOME"/direnv/layouts/
    #       echo -n "$PWD" | shasum | cut -d ' ' -f 1
    #     )}"
    #   }
    # '';
    programs.direnv.nix-direnv.enable = true;
    programs.zsh.initExtra = ''
      # nix-direnv
      nixify() {
        if [ ! -e ./.envrc ]; then
          echo "use nix" > .envrc
          direnv allow
        fi
        if [[ ! -e shell.nix ]] && [[ ! -e default.nix ]]; then
          cat > default.nix <<'EOF'
      with import <nixpkgs> {};
      mkShellNoCC {
        nativeBuildInputs = [
          bashInteractive
        ];
      }
      EOF
          ''${EDITOR:-vim} default.nix
        fi
      }

      flakifiy() {
        if [ ! -e flake.nix ]; then
          nix flake new -t github:nix-community/nix-direnv .
        elif [ ! -e .envrc ]; then
          echo "use flake" > .envrc
          direnv allow
        fi
        ''${EDITOR:-vim} flake.nix
      }
    '';
  };
}
