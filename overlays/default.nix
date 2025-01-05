# https://discourse.nixos.org/t/in-overlays-when-to-use-self-vs-super/2968/12
{ inputs }:

final: prev: {
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
    src = old.src.override {
      rev = "496b2e66aa10bdcb6f033bf8118f1972203ee7b0";
      hash = "sha256-OncfatdtdEavVF5Y5hLITgx9wz1Z29bX4P/uxmojvDI=";
    };
  });

  # https://github.com/NixOS/nixpkgs/pull/313497
  nixos-option = final.nixos-option-git;

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
  #   };

  wallpapers =
    final.lib.packagesFromDirectoryRecursive {
      inherit (final) callPackage;
      directory = ../pkgs/wallpapers;
    }
    // {
      default = final.wallpapers.lake;
    };

  yuzu-ea = final.lib.optionalAttrs final.stdenv.isLinux (
    inputs.yuzu.packages.${final.stdenv.system}.early-access.overrideAttrs (old: {
      # error: 'VK_DRIVER_ID_MESA_AGXV' was not declared in this scope
      postPatch =
        (old.postPatch or "")
        + ''
          rm -r externals/Vulkan-Utility-Libraries
          ln -s ${final.vulkan-utility-libraries.src} externals/Vulkan-Utility-Libraries
        '';
    })
  );
}
