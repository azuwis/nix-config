# https://discourse.nixos.org/t/in-overlays-when-to-use-self-vs-super/2968/12

self: super: {
  # pkgs
  # cemu = super.cemu.overrideAttrs (old: {
  #   postPatch = (old.postPatch or "") + ''
  #     sed -i '/\/\/ already connected\?/,+2 d' src/input/api/DSU/DSUControllerProvider.cpp
  #   '';
  # });

  # override
  # https://github.com/NixOS/nixpkgs/issues/267536
  borgbackup = super.borgbackup.overrideAttrs (
    old:
    self.lib.optionalAttrs (self.stdenv.isDarwin && self.stdenv.isx86_64) {
      disabledTests = (old.disabledTests or [ ]) ++ [
        "test_overwrite"
        "test_sparse_file"
      ];
    }
  );
  # disable fcitx5-configtool
  libsForQt5 = super.libsForQt5.overrideScope (
    _: scopeSuper: {
      fcitx5-with-addons = scopeSuper.fcitx5-with-addons.override { withConfigtool = false; };
    }
  );
  # https://github.com/NixOS/nixpkgs/issues/320900
  # https://github.com/NixOS/nixpkgs/pull/79344
  mpv-unwrapped =
    (super.mpv-unwrapped.override {
      swift =
        let
          CommandLineTools = "/Library/Developer/CommandLineTools";
        in
        self.stdenv.mkDerivation {
          name = "swift-CommandLineTools-0.0.0";
          phases = [
            "installPhase"
            "fixupPhase"
          ];

          propagatedBuildInputs = [ self.darwin.DarwinTools ];

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
        preConfigure = if self.stdenv.isDarwin then "" else old.preConfigure;
      });
  # https://github.com/nix-community/nix-zsh-completions/pull/52
  nix-zsh-completions = super.nix-zsh-completions.overrideAttrs (old: {
    src = old.src.override {
      rev = "496b2e66aa10bdcb6f033bf8118f1972203ee7b0";
      hash = "sha256-OncfatdtdEavVF5Y5hLITgx9wz1Z29bX4P/uxmojvDI=";
    };
  });
  # https://github.com/NixOS/nixpkgs/pull/315654
  nixos-option = self.callPackage "${
    self.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "1bd0fb37624cc63976e8421a7d2102807f15b366";
      hash = "sha256-QJszuTlTbYYFaFqdU61ePUhhJII+a4HOTfwUKFri130=";
      sparseCheckout = [ "pkgs/tools/nix/nixos-option/" ];
      nonConeMode = true;
    }
  }/pkgs/tools/nix/nixos-option" { };
  # python3 = super.python3.override {
  #   packageOverrides = pyself: pysuper: {
  #     pysonybraviapsk = self.python3.pkgs.callPackage ../pkgs/pysonybraviapsk { };
  #   };
  # };
  # python3Packages = self.python3.pkgs;
  # sway-unwrapped = super.sway-unwrapped.override {
  #   wlroots = self.wlroots_0_16.overrideAttrs (old: {
  #     postPatch =
  #       (old.postPatch or "") + ''
  #         substituteInPlace render/gles2/renderer.c --replace-fail "glFlush();" "glFinish();"
  #       '';
  #   });
  # };
}
