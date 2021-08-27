[
  (self: super: {
    fetchgitSparse = super.callPackage ./pkgs/fetchgitSparse { };
    nibar = super.callPackage ./pkgs/nibar { };
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
    zsh-fzf-tab = super.zsh-fzf-tab.overrideAttrs (o: rec {
      patches = [ ./pkgs/zsh-fzf-tab/darwin.patch ];
      meta.platforms = super.lib.platforms.unix;
    });
  })
]
