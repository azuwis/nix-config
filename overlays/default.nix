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
  libsForQt5 = prev.libsForQt5.overrideScope (
    qt5final: qt5prev: {
      fcitx5-with-addons = qt5prev.fcitx5-with-addons.override { withConfigtool = false; };
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
        let
          CommandLineTools = "/Library/Developer/CommandLineTools";
        in
        final.stdenv.mkDerivation {
          name = "swift-CommandLineTools-0.0.0";
          phases = [
            "installPhase"
            "fixupPhase"
          ];

          propagatedBuildInputs = [ final.darwin.DarwinTools ];

          installPhase = ''
            mkdir -p $out/bin $out/lib
            ln -s ${CommandLineTools}/usr/bin/swift $out/bin
            ln -s ${CommandLineTools}/usr/lib/swift $out/lib
            ln -s ${CommandLineTools}/SDKs $out
          '';

          setupHook = builtins.toFile "hook" ''
            addCommandLineTools() {
                echo >&2
                echo "WARNING: this is impure and unreliable, make sure the CommandLineTools are installed!" >&2
                echo "  $ xcode-select --install" >&2
                echo >&2
                [ -d ${CommandLineTools} ]
                export NIX_LDFLAGS+=" -L@out@/lib/swift/macosx"
                export SWIFT=swift
                export SWIFT_LIB_DYNAMIC=@out@/lib/swift/macosx
                export MACOS_SDK="@out@/SDKs/MacOSX.sdk"
            }

            prePhases+=" addCommandLineTools"
          '';

          __impureHostDeps = [ CommandLineTools ];
        };
    }).overrideAttrs
      (old: {
        preConfigure = if final.stdenv.isDarwin then "" else old.preConfigure;
      });

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
