[
  (self: super: {
    fetchgitSparse = super.callPackage ./pkgs/fetchgitSparse { };
    fmenu = super.callPackage ./pkgs/fmenu { };
    jetbrains-mono-nerdfont = super.callPackage ./pkgs/nerdfonts {
      font = "JetBrainsMono/Ligatures";
    };
    kitty = super.kitty.overrideAttrs (
      o: rec {
        NIX_CFLAGS_COMPILE = "-Wno-deprecated-declarations";
      }
    );
    nibar = super.callPackage ./pkgs/nibar { };
    openssh_8_7 = super.openssh.overrideAttrs (
      o: rec {
        version = "8.7p1";
        src = super.fetchurl {
          url = "mirror://openbsd/OpenSSH/portable/openssh-${version}.tar.gz";
          sha256 = "090yxpi03pxxzb4ppx8g8hdpw7c4nf8p0avr6c7ybsaana5lp8vw";
        };
      }
    );
    rime-csp = super.callPackage ./pkgs/rime-csp { };
    sf-symbols = self.sf-symbols-minimal;
    sf-symbols-app = super.callPackage ./pkgs/sf-symbols {
      app = true;
      fonts = false;
    };
    sf-symbols-full = super.callPackage ./pkgs/sf-symbols { full = true; };
    sf-symbols-minimal = super.callPackage ./pkgs/sf-symbols { };
    simple-bar = super.callPackage ./pkgs/simple-bar { };
    sketchybar = super.callPackage ./pkgs/sketchybar { };
    spacebar = super.callPackage ./pkgs/spacebar { };
    redsocks2 = super.callPackage ./pkgs/redsocks2 { };
    yabai = super.callPackage ./pkgs/yabai { };
    zsh-fzf-tab = super.zsh-fzf-tab.overrideAttrs (
      o: rec {
        patches = [ ./pkgs/zsh-fzf-tab/darwin.patch ];
        meta.platforms = super.lib.platforms.unix;
      }
    );
  }
  )
]
