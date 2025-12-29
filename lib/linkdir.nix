{
  config,
  lib,
  pkgs,
  name,
  dir ? "",
}:

let
  # Ref: nixpkgs/nixos/modules/system/etc/etc.nix
  activate = pkgs.writeShellScript "activate-${name}" ''
    set -euo pipefail

    realdir="''${1:-${dir}}"
    olddir="$realdir/.local/state/linkdir/${name}"

    echo "setting up $realdir"

    if [ ! -w "$realdir" ]; then
      echo "$realdir not writable, exit"
      exit
    fi

    newdir="${path}"
    while read -r -d $'\0' file; do
      source=$(readlink -f "$newdir/$file")
      target="$realdir/$file"
      if [ ! -e "$target" ]; then
        echo "new: $target -> $source"
        mkdir -p "$(dirname "$target")"
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
    done < <(find "$newdir/" -type l -printf '%P\0')

    if [ -e "$olddir" ]; then
      while read -r -d $'\0' file; do
        if [ ! -e "$newdir/$file" ]; then
          if [ -L "$realdir/$file" ]; then
            echo "remove: $realdir/$file"
            rm "$realdir/$file"
          else
            echo "skip remove: $realdir/$file, not a symlink"
          fi
        fi
      done < <(find "$olddir/" -type l -printf '%P\0')

      while read -r -d $'\0' dir; do
        if [ -d "$realdir/$dir" ]; then
          rmdir --ignore-fail-on-non-empty "$realdir/$dir"
        fi
      done < <(find "$olddir/" -depth -mindepth 1 -type d -printf '%P\0')
    fi

    mkdir -p "$(dirname "$olddir")"
    ln -sfn "$newdir" "$olddir"
  '';

  path = pkgs.runCommandLocal name { } ''
    set -euo pipefail

    makeEntry() {
      src="$1"
      target="$2"

      if [[ "$src" = *'*'* ]]; then
        # If the source name contains '*', perform globbing.
        mkdir -p "$out/$target"
        for fn in $src; do
            ln -s "$fn" "$out/$target/"
        done
      else
        mkdir -p "$out/$(dirname "$target")"
        if ! [ -e "$out/$target" ]; then
          ln -s "$src" "$out/$target"
        else
          echo "duplicate entry $target -> $src"
          if [ "$(readlink "$out/$target")" != "$src" ]; then
            echo "mismatched duplicate entry $(readlink "$out/$target") <-> $src"
            ret=1
          fi
        fi
      fi
    }

    mkdir "$out"
    ${lib.concatMapStringsSep "\n" (
      entry:
      lib.escapeShellArgs [
        "makeEntry"
        # Force local source paths to be added to the store
        "${entry.source}"
        entry.target
      ]
    ) (lib.filter (f: f.enable) (lib.attrValues config.${name}.file))}
  '';
in

{
  ${name} = {
    file = lib.mkOption {
      default = { };
      description = ''
        Set of files that have to be linked in {file}`${dir}`.
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
                    Whether this file should be generated. This option allows specific files to be disabled.
                  '';
                };

                target = lib.mkOption {
                  type = lib.types.str;
                  description = ''
                    Name of symlink (relative to {file}`${dir}`). Defaults to the attribute name.
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
                    name' = "${name}-" + lib.replaceStrings [ "/" ] [ "-" ] name;
                  in
                  lib.mkDerivedConfig options.text (pkgs.writeText name')
                );
              };
            }
          )
        );
    };

    activate = lib.mkOption {
      readOnly = true;
      default = activate;
    };

    path = lib.mkOption {
      readOnly = true;
      default = path;
    };
  };
}
