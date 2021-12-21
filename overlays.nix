let
  pkgsX64 = import <nixpkgs> { localSystem = "x86_64-darwin"; overlays = []; };
in
[
  (self: super: {
    # pkgs
    anime4k = super.callPackage ./pkgs/anime4k { };
    fetchgitSparse = super.callPackage ./pkgs/fetchgitSparse { };
    jetbrains-mono-nerdfont = super.callPackage ./pkgs/nerdfonts { font = "JetBrainsMono/Ligatures"; };
    nibar = super.callPackage ./pkgs/nibar { };
    redsocks2 = super.callPackage ./pkgs/redsocks2 { };
    rime-csp = super.callPackage ./pkgs/rime-csp { };
    scripts = super.callPackage ./pkgs/scripts { };
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
    emacsUnstable = (super.emacs.override { srcRepo = true; nativeComp = false; }).overrideAttrs (
      o: rec {
        version = "28";
        src = super.fetchgit {
          url = "https://github.com/emacs-mirror/emacs.git";
          rev = "emacs-28.0.90";
          sha256 = "sha256-db8D5X264wFJpVxeFcNYh3U3NhSO7wvb9p+QM8Hrm0o=";
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
        buildInputs = o.buildInputs ++
          super.lib.optionals
            (super.stdenv.isDarwin && (builtins.hasAttr "UserNotifications" super.darwin.apple_sdk.frameworks))
          [ super.darwin.apple_sdk.frameworks.UserNotifications ];
        patches = super.lib.optionals super.stdenv.isDarwin [ ./pkgs/kitty/apple-sdk-11.patch ];
      }
    );
    # olive-editor = super.libsForQt515.callPackage <nixpkgs/pkgs/applications/video/olive-editor> {
    #   inherit (super.darwin.apple_sdk.frameworks) CoreFoundation;
    # };
  }
  )
]
