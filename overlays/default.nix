# https://nixos.org/manual/nixpkgs/stable/#chap-overlays
# Can be use as `~/.config/nixpkgs/overlays/`.
# Also used by `common/nixpkgs/default.nix` `pkgs/default.nix` `scripts/update.nix`

let
  inputs = import ../inputs { };
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

    # lua = prev.lua.override {
    #   packageOverrides =
    #     luafinal: luaprev:
    #     final.lib.packagesFromDirectoryRecursive {
    #       inherit (final.lua.pkgs) callPackage;
    #       directory = ../pkgs/lua;
    #     };
    # };
    # luaPackages = final.lua.pkgs;

    # 0.8.1 make vulkan app segfault when closing, 0.8.2 make vulkan unusable `corrupted double-linked list`
    mangohud = prev.mangohud.overrideAttrs (old: {
      version = "0.8.2-unstable-2025-12-09";
      src = old.src.override {
        tag = null;
        rev = "744cb9150f8edaa69c45e87fc976afd87757fc66";
        hash = "sha256-SOXoSBx+OWvtWlr4dNeaje6ktp6/A+MauQ29a1FgQ2M=";
      };
      # Remove buildIntputs when 0.8.2 hit nixos-25.11
      buildInputs = final.lib.subtractLists [ final.nlohmann_json final.glew ] old.buildInputs;
      # Currently broke after 0.8.2-unstable-2025-12-17, due to vulkan-headers subproject bump
      passthru.enable = false;
      passthru.updateScript = final.nix-update-script { extraArgs = [ "--version=branch" ]; };
    });

    # https://github.com/nix-community/nix-zsh-completions/pull/55
    nix-zsh-completions = prev.nix-zsh-completions.overrideAttrs (old: {
      version = "0.5.1-unstable-2025-12-14";
      src = old.src.override {
        tag = null;
        rev = "4e544362fdc766835dd1a6151d49299c7ad014ed";
        hash = "sha256-4wcINY3L9BZ4dtcqcP+d0OgE/Q2UHnu0GilgMokrzcI=";
      };
      passthru = (old.passthru or { }) // {
        updateScript = final.nix-update-script { extraArgs = [ "--version=branch=pull/55/merge" ]; };
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

    # Remove when vimPlugins.lualine-nvim updated
    # https://github.com/NixOS/nixpkgs/pull/464616
    # vimPlugins = prev.vimPlugins.extend (
    #   vimfinal: vimprev: {
    #     lualine-nvim = final.neovimUtils.buildNeovimPlugin {
    #       luaAttr = final.neovim-unwrapped.lua.pkgs.lualine-nvim.overrideAttrs (old: {
    #         knownRockspec =
    #           (final.fetchurl {
    #             url = "mirror://luarocks/lualine.nvim-scm-1.rockspec";
    #             sha256 = "01cqa4nvpq0z4230szwbcwqb0kd8cz2dycrd764r0z5c6vivgfzs";
    #           }).outPath;
    #       });
    #     };
    #   }
    # );

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
