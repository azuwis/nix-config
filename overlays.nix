let
  pkgsX64 = import <nixpkgs> { localSystem = "x86_64-darwin"; overlays = []; };
in
[
  (self: super:
    let
      lib = super.lib;
    in
    rec {
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
          rev = "995a623594de27d398f0d97fcab9277e37fe29d1";
          sha256 = "0mhn9kvcvc7cs87v8ndb8dpkyzkvh83ma083v1kdxgvjhkwcdz45";
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
    python39 = super.python39.override {
      packageOverrides = self: super: {
        beautifulsoup4 = super.beautifulsoup4.overrideAttrs (old: {
          propagatedBuildInputs = lib.remove super.lxml old.propagatedBuildInputs;
        });
      };
    };
    python39Packages = python39.pkgs;
    # olive-editor = super.libsForQt515.callPackage <nixpkgs/pkgs/applications/video/olive-editor> {
    #   inherit (super.darwin.apple_sdk.frameworks) CoreFoundation;
    # };
    # kitty = super.kitty.overrideAttrs (
    #   o: rec {
    #     buildInputs = o.buildInputs ++ [ super.darwin.apple_sdk.frameworks.UserNotifications ];
    #   }
    # );
    openssh_8_7 = super.openssh.overrideAttrs (
      o: rec {
        version = "8.7p1";
        src = super.fetchurl {
          url = "mirror://openbsd/OpenSSH/portable/openssh-${version}.tar.gz";
          sha256 = "090yxpi03pxxzb4ppx8g8hdpw7c4nf8p0avr6c7ybsaana5lp8vw";
        };
      }
    );
  }
  )
]
