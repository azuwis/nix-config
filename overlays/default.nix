let
  inputs = import ../inputs;
in

# https://discourse.nixos.org/t/in-overlays-when-to-use-self-vs-super/2968/12
[
  (import (inputs.agenix.outPath + "/overlay.nix"))
  (import (inputs.nixpkgs.outPath + "/pkgs/top-level/by-name-overlay.nix") ../pkgs/by-name)

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
    # https://github.com/nix-community/nix-zsh-completions/pull/55
    nix-zsh-completions = prev.nix-zsh-completions.overrideAttrs (old: {
      version = "0.5.1-unstable-2025-03-26";
      src = old.src.override {
        tag = null;
        rev = "c2553ae08a6e688e82a7e0b65f51203eb4ab8a45";
        hash = "sha256-4g0lJ+vkr0H0AgSQS2kDiidHCChKNh1VphU/mKFkioQ=";
      };
      passthru = (old.passthru or { }) // {
        updateScript = final.nix-update-script { extraArgs = [ "--version=branch=pull/55/head" ]; };
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

    # vimPlugins =
    #   prev.vimPlugins
    #   // final.lib.packagesFromDirectoryRecursive {
    #     inherit (final) callPackage;
    #     directory = ../pkgs/vim;
    #   }
    #   # Remove when vimPlugins.LazyVim updated
    #   // {
    #     LazyVim = prev.vimPlugins.LazyVim.overrideAttrs (old: rec {
    #       version = "14.14.0";
    #       src = old.src.override {
    #         rev = "v${version}";
    #         sha256 = "sha256-1q8c2M/FZxYg4TiXe9PK6JdR4wKBgPbxRt40biIEBaY=";
    #       };
    #       passthru = (old.passthru or { }) // {
    #         updateScript = final.nix-update-script { };
    #       };
    #     });
    #   };

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
