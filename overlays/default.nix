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
  nixos-option =
    let
      prefix = ''(builtins.getFlake \\\"/etc/nixos\\\").nixosConfigurations.\$(hostname)'';
    in
    self.runCommand "nixos-option" { buildInputs = [ self.makeWrapper ]; } ''
      makeWrapper ${super.nixos-option}/bin/nixos-option $out/bin/nixos-option \
        --add-flags --config_expr \
        --add-flags "\"${prefix}.config\"" \
        --add-flags --options_expr \
        --add-flags "\"${prefix}.options\""
    '';
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
  # yabai = self.callPackage ../pkgs/yabai { };
}
