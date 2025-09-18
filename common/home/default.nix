{
  config,
  lib,
  pkgs,
  ...
}:

# Ref: nixpkgs/nixos/modules/system/etc/etc.nix
let
  activate = pkgs.writeShellScript "activate-home" ''
    realhome="$1"
    oldhome="$2"

    echo "setting up $realhome"

    if [ ! -w "$realhome" ]; then
      echo "$realhome not writable, exit"
      exit
    fi

    newhome="${home}/home"
    while read -r -d $'\0' file; do
      source=$(readlink -f "$newhome/$file")
      target="$realhome/$file"
      if [ ! -e "$target" ]; then
        echo "new: $target -> $source"
        ln -sn "$source" "$target"
      else
        if [ -L "$target" ]; then
          if [ "$(readlink "$target")" != "$source" ]; then
            echo "replace: $target -> $source"
            ln -sfn "$source" "$target"
          # else
          #   echo "keep: $target -> $source"
          fi
        else
          echo "skip replace: $target, not a symlink"
        fi
      fi
    done < <(find "$newhome" -type l -printf '%P\0')

    if [ -e "$oldhome" ]; then
      while read -r -d $'\0' file; do
        if [ ! -e "$newhome/$file" ]; then
          if [ -L "$realhome/$file" ]; then
            echo "remove: $realhome/$file"
            rm "$realhome/$file"
          else
            echo "skip remove: $realhome/$file, not a symlink"
          fi
        fi
      done < <(find "$oldhome" -type l -printf '%P\0')
    fi
  '';

  home = pkgs.runCommandLocal "home" { } ''
    set -euo pipefail

    makeHomeEntry() {
      src="$1"
      target="$2"

      if [[ "$src" = *'*'* ]]; then
        # If the source name contains '*', perform globbing.
        mkdir -p "$out/home/$target"
        for fn in $src; do
            ln -s "$fn" "$out/home/$target/"
        done
      else
        mkdir -p "$out/home/$(dirname "$target")"
        if ! [ -e "$out/home/$target" ]; then
          ln -s "$src" "$out/home/$target"
        else
          echo "duplicate entry $target -> $src"
          if [ "$(readlink "$out/home/$target")" != "$src" ]; then
            echo "mismatched duplicate entry $(readlink "$out/home/$target") <-> $src"
            ret=1
          fi
        fi
      fi
    }

    mkdir -p "$out/home"
    ${lib.concatMapStringsSep "\n" (
      homeEntry:
      lib.escapeShellArgs [
        "makeHomeEntry"
        # Force local source paths to be added to the store
        "${homeEntry.source}"
        homeEntry.target
      ]
    ) (lib.filter (f: f.enable) (lib.attrValues config.home.file))}
  '';
in

{
  options = {
    home.file = lib.mkOption {
      default = { };
      description = ''
        Set of files that have to be linked in {file}`~/`.
        NOTE: Beware those files will NOT be cleaned up.
      '';

      type =
        with lib.types;
        attrsOf (
          submodule (
            {
              name,
              config,
              options,
              ...
            }:
            {
              options = {
                enable = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = ''
                    Whether this file should be generated.  This
                    option allows specific /etc files to be disabled.
                  '';
                };

                target = lib.mkOption {
                  type = lib.types.str;
                  description = ''
                    Name of symlink (relative to
                    {file}`~/`).  Defaults to the attribute
                    name.
                  '';
                };

                text = lib.mkOption {
                  default = null;
                  type = lib.types.nullOr lib.types.lines;
                  description = "Text of the file.";
                };

                source = lib.mkOption {
                  type = lib.types.path;
                  description = "Path of the source file.";
                };
              };

              config = {
                target = lib.mkDefault name;
                source = lib.mkIf (config.text != null) (
                  let
                    name' = "home-" + lib.replaceStrings [ "/" ] [ "-" ] name;
                  in
                  lib.mkDerivedConfig options.text (pkgs.writeText name')
                );
              };
            }
          )
        );
    };

    home.activate = lib.mkOption {
      readOnly = true;
      default = activate;
    };
  };

  config = {
    environment.systemPackages = [ home ];
    environment.pathsToLink = [ "/home" ];
  };
}
