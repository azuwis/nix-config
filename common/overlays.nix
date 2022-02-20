[
  (self: super: {
    # pkgs
    anime4k = super.callPackage ../pkgs/anime4k { };
    jetbrains-mono-nerdfont = super.callPackage ../pkgs/nerdfonts { font = "JetBrainsMono/Ligatures"; };
    legacyfox = super.callPackage ../pkgs/legacyfox { };
    nibar = super.callPackage ../pkgs/nibar { };
    redsocks2 = super.callPackage ../pkgs/redsocks2 { };
    rime-idvel = super.callPackage ../pkgs/rime-idvel { };
    scripts = super.callPackage ../pkgs/scripts { };
    sf-symbols = self.sf-symbols-minimal;
    sf-symbols-app = super.callPackage ../pkgs/sf-symbols { app = true; fonts = false; };
    sf-symbols-full = super.callPackage ../pkgs/sf-symbols { full = true; };
    sf-symbols-minimal = super.callPackage ../pkgs/sf-symbols { };
    # sketchybar = super.callPackage ../pkgs/sketchybar { };
  })
]
