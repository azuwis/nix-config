let
  CommandLineTools = "/Library/Developer/CommandLineTools";
  pkgsX64 = import <nixpkgs> { localSystem = "x86_64-darwin"; overlays = []; };
in
[
  (self: super: {
    # x64
    # hydra-check --arch aarch64-darwin --channel nixpkgs/nixpkgs-unstable-aarch64-darwin ansible
    # ansible = pkgsX64.ansible;

    # overrides
    emacsUnstable = (super.emacs.override { srcRepo = true; nativeComp = false; }).overrideAttrs (
      o: rec {
        version = "unstable-2022-01-08";
        src = super.fetchgit {
          url = "https://github.com/emacs-mirror/emacs.git";
          rev = "d193801f59822554d28e497da146d982f5ab7995"; # tags/emacs-2*
          sha256 = "04jd742ys4saa0jxs6carn8wsidm38m7pdcryc42rb7y1a9l3zyf";
        };
        patches = [
          ../pkgs/emacs/fix-window-role.patch
          ../pkgs/emacs/no-titlebar.patch
        ];
        postPatch = o.postPatch + ''
          substituteInPlace lisp/loadup.el \
          --replace '(emacs-repository-get-branch)' '"master"'
        '';
        CFLAGS = "-DMAC_OS_X_VERSION_MAX_ALLOWED=110203 -g -O2";
      }
    );
    # mpv-unwrapped = (super.mpv-unwrapped.override { swiftSupport = true; }).overrideAttrs (
    #   o: {
    #     wafConfigureFlags = o.wafConfigureFlags ++ [
    #     ];
    #   }
    # );
    swift = super.stdenv.mkDerivation {
      name = "swift-CommandLineTools-0.0.0";
      phases = [ "installPhase" "fixupPhase" ];

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
              export MACOS_SDK_VERSION=$(sw_vers -productVersion | awk -F. '{print $1 "." $2}')
              export MACOS_SDK=@out@/SDKs/MacOSX$MACOS_SDK_VERSION.sdk
          }

          prePhases+=" addCommandLineTools"
      '';

      __impureHostDeps = [ CommandLineTools ];
    };
    # olive-editor = super.libsForQt515.callPackage <nixpkgs/pkgs/applications/video/olive-editor> {
    #   inherit (super.darwin.apple_sdk.frameworks) CoreFoundation;
    # };
    yabai = let
      replace = {
        "aarch64-darwin" = "--replace '-arch x86_64' ''";
        "x86_64-darwin" = "--replace '-arch arm64e' '' --replace '-arch arm64' ''";
      }.${super.pkgs.stdenv.hostPlatform.system};
    in super.yabai.overrideAttrs(
      o: rec {
        version = "unstable-2022-01-22";
        src = super.fetchFromGitHub {
          owner = "koekeishiya";
          repo = "yabai";
          rev = "fe86f24a21772810cd186d1b5bd2eff84b2701a9";
          sha256 = "0m40i07gls47l5ibr6ys0qnqnfhqk9fnq0k7wdjmy04l859zqpw3";
        };
        prePatch = ''
          substituteInPlace makefile ${replace};
        '';
        buildPhase = ''
          PATH=/usr/bin:/bin /usr/bin/make install
        '';
      }
    );
  }
  )
]
