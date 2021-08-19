[( self: super: {
  nibar = super.callPackage ./pkgs/nibar {};
  rime-csp = super.callPackage ./pkgs/rime-csp {};
  sf-symbols = super.callPackage ./pkgs/sf-symbols {};
  simple-bar = super.callPackage ./pkgs/simple-bar {};
  yabai = super.callPackage ./pkgs/yabai {};
  zsh-fzf-tab = super.zsh-fzf-tab.overrideAttrs (o: rec {
    patches = [ ./pkgs/zsh-fzf-tab/darwin.patch ];
    meta.platforms = super.lib.platforms.unix;
  });
})]
