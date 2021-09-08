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

    # overrides
    emacsUnstable = (super.emacs.override { srcRepo = true; nativeComp = true; }).overrideAttrs (
      o: rec {
        version = "28";
        src = super.fetchgit {
          url = "git://git.sv.gnu.org/emacs.git";
          rev = "f85b8678c4a08fd91d9b5f32dcde2f0b21bc6e38";
          sha256 = "06wnzyvdzgpy7kd13japggz5nvdv4lvjw07c17xik0s4xxn20nsi";
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
    openssh_8_7 = super.openssh.overrideAttrs (
      o: rec {
        version = "8.7p1";
        src = super.fetchurl {
          url = "mirror://openbsd/OpenSSH/portable/openssh-${version}.tar.gz";
          sha256 = "090yxpi03pxxzb4ppx8g8hdpw7c4nf8p0avr6c7ybsaana5lp8vw";
        };
      }
    );
    zsh-fzf-tab = super.zsh-fzf-tab.overrideAttrs (
      o: rec {
        patches = [ ./pkgs/zsh-fzf-tab/darwin.patch ];
        meta.platforms = super.lib.platforms.unix;
      }
    );
  }
  )
]
