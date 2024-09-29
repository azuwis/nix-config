# https://discourse.nixos.org/t/in-overlays-when-to-use-self-vs-super/2968/12

final: prev: {
  # override
  # https://github.com/NixOS/nixpkgs/issues/267536
  borgbackup = prev.borgbackup.overrideAttrs (
    old:
    final.lib.optionalAttrs (final.stdenv.isDarwin && final.stdenv.isx86_64) {
      disabledTests = (old.disabledTests or [ ]) ++ [
        "test_overwrite"
        "test_sparse_file"
      ];
    }
  );

  # cemu = prev.cemu.overrideAttrs (old: {
  #   postPatch = (old.postPatch or "") + ''
  #     sed -i '/\/\/ already connected\?/,+2 d' src/input/api/DSU/DSUControllerProvider.cpp
  #   '';
  # });

  # https://github.com/intel/intel-vaapi-driver/pull/566
  intel-vaapi-driver = prev.intel-vaapi-driver.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (final.fetchpatch {
        url = "https://github.com/intel/intel-vaapi-driver/commit/4206d0e15363d188f30f2f3dbcc212fef206fc1d.patch";
        hash = "sha256-unCnAGM36sRcW4inaN21IqVOhHY9YB+iJYGgdFCxWQ0=";
      })
    ];
  });

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

  # https://github.com/NixOS/nixpkgs/issues/320900
  # https://github.com/NixOS/nixpkgs/pull/79344
  mpv-unwrapped =
    (prev.mpv-unwrapped.override {
      # For `--vo=gpu-next` on macOS, useful for DobbyVision 10Bit videos
      vulkanSupport = true;
      swift =
        (import
          (builtins.fetchTarball {
            # nixpkgs-24.05-darwin
            url = "https://github.com/NixOS/nixpkgs/archive/ced0da1e7e7d50f1352bc6bdd25af8ae55eb3934.tar.gz";
            sha256 = "01wqw1jsngicri7b09npg70xdzyrfq787kka9xx1q1h3p1jwnsag";
          })
          {
            inherit (final.stdenv) system;
          }
        ).swift;
    }).overrideAttrs
      (
        old:
        final.lib.optionalAttrs final.stdenv.isDarwin {
          patches = (old.patches or [ ]) ++ [ ../patches/mpv-darwin.patch ];
          postInstall = ''
            # Use a standard font
            mkdir -p $out/share/mpv
            ln -s ${final.freefont_ttf}/share/fonts/truetype/FreeSans.ttf $out/share/mpv/subfont.ttf

            pushd ../TOOLS
            cp mpv_identify.sh umpv $out/bin/
            popd

            mkdir -p $out/Applications
            cp -r mpv.app $out/Applications
          '';
        }
      );

  # https://github.com/Mic92/nix-update/pull/269
  # nix-update = prev.nix-update.overridePythonAttrs (old: {
  #   version = "1.5.0-unstable-2024-08-21";
  #   src = old.src.override {
  #     rev = "737121eccb67542e8c004c64da833fede2e80c64";
  #     hash = "sha256-xn0dC4M3mfItxP+s3/v3Hz/CSKp74VH/gMfufKxl9/4=";
  #   };
  #   passthru.updateScript = final.nix-update-script { extraArgs = [ "--version=branch" ]; };
  # });

  # https://github.com/nix-community/nix-zsh-completions/pull/52
  nix-zsh-completions = prev.nix-zsh-completions.overrideAttrs (old: {
    src = old.src.override {
      rev = "496b2e66aa10bdcb6f033bf8118f1972203ee7b0";
      hash = "sha256-OncfatdtdEavVF5Y5hLITgx9wz1Z29bX4P/uxmojvDI=";
    };
  });

  # https://github.com/NixOS/nixpkgs/pull/313497
  # This IFD breaks `nix flake show`, need to run `nix --option allow-import-from-derivation true flake show`.
  # Be ware of the eval cache, may need `--option eval-cache false`.
  nixos-option = final.callPackage "${
    final.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "172f04cac31ef53e7e6c1a96e0db5514993f7208";
      hash = "sha256-v0o+LZ8kAWHOVAfLNV3du6kwXVZdNQH8McsVM9rNmVQ=";
      sparseCheckout = [ "pkgs/tools/nix/nixos-option/" ];
      nonConeMode = true;
    }
  }/pkgs/tools/nix/nixos-option" { };

  # python3 = prev.python3.override {
  #   packageOverrides =
  #     pyfinal: pyprev:
  #     final.lib.packagesFromDirectoryRecursive {
  #       inherit (final.python3.pkgs) callPackage;
  #       directory = ../pkgs/python;
  #     };
  # };
  # python3Packages = final.python3.pkgs;

  # sway-unwrapped = prev.sway-unwrapped.override {
  #   wlroots = final.wlroots_0_16.overrideAttrs (old: {
  #     postPatch =
  #       (old.postPatch or "") + ''
  #         substituteInPlace render/gles2/renderer.c --replace-fail "glFlush();" "glFinish();"
  #       '';
  #   });
  # };

  wallpapers =
    final.lib.packagesFromDirectoryRecursive {
      inherit (final) callPackage;
      directory = ../pkgs/wallpapers;
    }
    // {
      default = final.wallpapers.lake;
    };
}
