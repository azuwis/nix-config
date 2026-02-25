{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.nps;

  nixpkgs =
    let
      str = toString pkgs.path;
    in
    # Allow reference to nixpkgs without copying to nix store again
    builtins.appendContext str {
      "${str}" = {
        path = true;
      };
    };

  npsPackageCache =
    pkgs.runCommand "nps-package-cache"
      {
        nativeBuildInputs = [
          cfg.package
          pkgs.nix
          pkgs.writableTmpDirAsHomeHook
        ];
        preferLocalBuild = true;
      }
      ''
        export NIX_STATE_DIR="$HOME/nix/state"
        export NIX_STORE_DIR="$HOME/nix/store"

        mkdir -p "$HOME/.config/nix"

        cat >"$HOME/.config/nix/nix.conf" <<EOF
        experimental-features = nix-command flakes
        flake-registry =
        EOF

        cat >"$HOME/.config/nix/registry.json" <<EOF
        {
          "flakes": [
            {
              "from": {
                "id": "nixpkgs",
                "type": "indirect"
              },
              "to": {
                "path": "${nixpkgs}",
                "type": "path"
              }
            }
          ],
          "version": 2
        }
        EOF

        NIX_PACKAGE_SEARCH_EXPERIMENTAL=true nps --debug --refresh
        cp -r "$HOME/.nix-package-search" "$out"
      '';

  npsWrapped =
    pkgs.runCommand "nps-wrapped"
      {
        inherit (cfg.package) meta;
        nativeBuildInputs = [
          pkgs.makeWrapper
        ];
        preferLocalBuild = true;
      }
      ''
        exe="${lib.getExe cfg.package}"
        makeWrapper "$exe" "$out/bin/$(basename "$exe")" \
          --set NIX_PACKAGE_SEARCH_CACHE_FOLDER_ABSOLUTE_PATH "${npsPackageCache}" \
          --set NIX_PACKAGE_SEARCH_EXPERIMENTAL "true"
      '';
in

{
  options.programs.nps = {
    enable = lib.mkEnableOption "nps and generate package cache";

    package = lib.mkPackageOption pkgs "nps" { };

    finalPackage = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = npsWrapped;
      description = ''
        Resulting nps package.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.finalPackage ];
  };

  meta.maintainers = with lib.maintainers; [ azuwis ];
}
