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
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/cl/claude-code/manifest.json
    claude-code = prev.claude-code.overrideAttrs (old: {
      version = "2.1.202";
      src = old.src.overrideAttrs {
        outputHashAlgo = "sha256";
        outputHash =
          {
            aarch64-darwin = "7414f707861e2fe5afef33a466f888a8d2170e5028f5e9d2858f1d3ef45ffca5";
            x86_64-linux = "71590202249892db3805ecd5b867f831f04b8129eaabd3f9a5bd4ba16b52c839";
          }
          .${final.stdenv.system};
      };
    });

    # disable fcitx5-configtool and fcitx5-qt5
    qt6Packages = prev.qt6Packages.overrideScope (
      qt6final: qt6prev: {
        fcitx5-with-addons = qt6prev.fcitx5-with-addons.override {
          libsForQt5.fcitx5-qt = final.emptyDirectory;
          withConfigtool = false;
        };
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

    # https://github.com/azuwis/nvd
    nvd = prev.nvd.overrideAttrs (old: {
      version = "0.2.4-unstable-2026-05-31";
      src = final.fetchFromGitHub {
        owner = "azuwis";
        repo = "nvd";
        rev = "3c24946a832e6cf29770dced1e11c87129390423";
        sha256 = "sha256-juuPRSXQE7gHWn2MnHkdjQ2QM2td5gRdWkvDELeWihQ=";
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
