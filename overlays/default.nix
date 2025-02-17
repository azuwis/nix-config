# https://discourse.nixos.org/t/in-overlays-when-to-use-self-vs-super/2968/12
{ inputs }:

[
  inputs.agenix.overlays.default
  (import "${inputs.nixpkgs}/pkgs/top-level/by-name-overlay.nix" ../pkgs/by-name)

  (final: prev: {
    # disable fcitx5-configtool
    qt6Packages = prev.qt6Packages.overrideScope (
      qt6final: qt6prev: {
        fcitx5-with-addons = qt6prev.fcitx5-with-addons.override { withConfigtool = false; };
      }
    );

    lua = prev.lua.override {
      packageOverrides =
        luafinal: luaprev:
        final.lib.packagesFromDirectoryRecursive {
          inherit (final.lua.pkgs) callPackage;
          directory = ../pkgs/lua;
        };
    };
    luaPackages = final.lua.pkgs;

    # https://github.com/nix-community/nix-zsh-completions/pull/52
    nix-zsh-completions = prev.nix-zsh-completions.overrideAttrs (old: {
      version = "0.5.1-unstable-2024-12-15";
      src = old.src.override {
        tag = null;
        rev = "4e654da12a28ebc272e7f6b7a60a1c8af3da84f0";
        hash = "sha256-L7N+TUag830IGD+lP8vwR0nWCXVfy87d5lTObYfBo8U=";
      };
      passthru = (old.passthru or { }) // {
        updateScript = final.nix-update-script { extraArgs = [ "--version=branch" ]; };
      };
    });

    # python3 = prev.python3.override {
    #   packageOverrides =
    #     pyfinal: pyprev:
    #     final.lib.packagesFromDirectoryRecursive {
    #       inherit (final.python3.pkgs) callPackage;
    #       directory = ../pkgs/python;
    #     };
    # };
    # python3Packages = final.python3.pkgs;

    vimPlugins =
      prev.vimPlugins
      // final.lib.packagesFromDirectoryRecursive {
        inherit (final) callPackage;
        directory = ../pkgs/vim;
      };

    wallpapers =
      final.lib.packagesFromDirectoryRecursive {
        inherit (final) callPackage;
        directory = ../pkgs/wallpapers;
      }
      // {
        default = final.wallpapers.lake;
      };
  })

  # (import ../overlays/lix.nix)
]
