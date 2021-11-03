let
  pkgsX64 = import <nixpkgs> { localSystem = "x86_64-darwin"; overlays = []; };
in
[
  (self: super: {
    # pkgs
    anime4k = super.callPackage ./pkgs/anime4k { };
    fetchgitSparse = super.callPackage ./pkgs/fetchgitSparse { };
    fmenu = super.callPackage ./pkgs/fmenu { };
    jetbrains-mono-nerdfont = super.callPackage ./pkgs/nerdfonts { font = "JetBrainsMono/Ligatures"; };
    nibar = super.callPackage ./pkgs/nibar { };
    redsocks2 = super.callPackage ./pkgs/redsocks2 { };
    rime-csp = super.callPackage ./pkgs/rime-csp { };
    sf-symbols = self.sf-symbols-minimal;
    sf-symbols-app = super.callPackage ./pkgs/sf-symbols { app = true; fonts = false; };
    sf-symbols-full = super.callPackage ./pkgs/sf-symbols { full = true; };
    sf-symbols-minimal = super.callPackage ./pkgs/sf-symbols { };
    simple-bar = super.callPackage ./pkgs/simple-bar { };
    sketchybar = super.callPackage ./pkgs/sketchybar { };
    spacebar = super.callPackage ./pkgs/spacebar { };
    yabai = super.callPackage ./pkgs/yabai { };

    # x64
    # hydra-check --arch aarch64-darwin --channel nixpkgs/nixpkgs-unstable-aarch64-darwin ansible
    # ansible = pkgsX64.ansible;
    # ansible-lint = pkgsX64.ansible-lint;
    # shellcheck = pkgsX64.shellcheck;

    # overrides
    emacsUnstable = (super.emacs.override { srcRepo = true; nativeComp = true; }).overrideAttrs (
      o: rec {
        version = "28";
        src = super.fetchgit {
          url = "git://git.sv.gnu.org/emacs.git";
          rev = "b506c5b217d4adf68013c15be0d1b16189de089b";
          sha256 = "1f1q9z21s0v8wmmy38nq3nra8x30k5kx6xz5cps8j11hybgf45d4";
        };
        patches = [
          ./pkgs/emacs/fix-window-role.patch
          ./pkgs/emacs/no-titlebar.patch
        ];
        postPatch = o.postPatch + ''
          substituteInPlace lisp/loadup.el \
          --replace '(emacs-repository-get-branch)' '"master"'
        '';
        CFLAGS = "-DMAC_OS_X_VERSION_MAX_ALLOWED=110203 -g -O2";
      }
    );
    kitty = super.kitty.overrideAttrs (
      o: rec {
        NIX_CFLAGS_COMPILE = "-Wno-deprecated-declarations";
      }
    );
    # olive-editor = super.libsForQt515.callPackage <nixpkgs/pkgs/applications/video/olive-editor> {
    #   inherit (super.darwin.apple_sdk.frameworks) CoreFoundation;
    # };
    # kitty = super.kitty.overrideAttrs (
    #   o: rec {
    #     buildInputs = o.buildInputs ++ [ super.darwin.apple_sdk.frameworks.UserNotifications ];
    #   }
    # );
  }
  )
]
