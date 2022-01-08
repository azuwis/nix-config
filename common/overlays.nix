[
  (self: super: {
    # pkgs
    anime4k = super.callPackage ../pkgs/anime4k { };
    fetchgitSparse = super.callPackage ../pkgs/fetchgitSparse { };
    jetbrains-mono-nerdfont = super.callPackage ../pkgs/nerdfonts { font = "JetBrainsMono/Ligatures"; };
    legacyfox = super.callPackage ../pkgs/legacyfox { };
    nibar = super.callPackage ../pkgs/nibar { };
    redsocks2 = super.callPackage ../pkgs/redsocks2 { };
    rime-csp = super.callPackage ../pkgs/rime-csp { };
    scripts = super.callPackage ../pkgs/scripts { };
    sf-symbols = self.sf-symbols-minimal;
    sf-symbols-app = super.callPackage ../pkgs/sf-symbols { app = true; fonts = false; };
    sf-symbols-full = super.callPackage ../pkgs/sf-symbols { full = true; };
    sf-symbols-minimal = super.callPackage ../pkgs/sf-symbols { };
    simple-bar = super.callPackage ../pkgs/simple-bar { };
    sketchybar = super.callPackage ../pkgs/sketchybar { };
    spacebar = super.callPackage ../pkgs/spacebar { };
    yabai = super.callPackage ../pkgs/yabai { };
  })
]
