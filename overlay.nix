self: super: rec {
  # pkgs
  anime4k = super.callPackage ./pkgs/anime4k { };
  jetbrains-mono-nerdfont = super.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
  legacyfox = super.callPackage ./pkgs/legacyfox { };
  nibar = super.callPackage ./pkgs/nibar { };
  redsocks2 = super.callPackage ./pkgs/redsocks2 { };
  rime-ice = super.callPackage ./pkgs/rime-ice { };
  scripts = super.callPackage ./pkgs/scripts { };
  sf-symbols = self.sf-symbols-minimal;
  sf-symbols-app = super.callPackage ./pkgs/sf-symbols { app = true; fonts = false; };
  sf-symbols-full = super.callPackage ./pkgs/sf-symbols { full = true; };
  sf-symbols-minimal = super.callPackage ./pkgs/sf-symbols { };
  sketchybar = super.callPackage ./pkgs/sketchybar {
    inherit (super.darwin.apple_sdk.frameworks) Carbon Cocoa SkyLight;
  };
  torrent-ratio = super.callPackage ./pkgs/torrent-ratio { };
  # uxplay = super.callPackage ./pkgs/uxplay { };

  # override
  emacsMac = (super.emacs.override { srcRepo = true; nativeComp = false; }).overrideAttrs (
    o: rec {
      version = "28.1";
      src = super.fetchgit {
        url = "https://github.com/emacs-mirror/emacs.git";
        rev = "5a223c7f2ef4c31abbd46367b6ea83cd19d30aa7"; # tags/emacs-2*
        sha256 = "01mfwl6lh79f9icrfw07dns3g0nqwc06k6fm3gr45iv1bjgg0z8g";
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
  nixos-option = let
    flake-compact = super.fetchFromGitHub {
      owner = "edolstra";
      repo = "flake-compat";
      rev = "12c64ca55c1014cdc1b16ed5a804aa8576601ff2";
      sha256 = "sha256-hY8g6H2KFL8ownSiFeMOjwPC8P0ueXpCVEbxgda3pko=";
    };
    prefix = ''(import ${flake-compact} { src = /etc/nixos; }).defaultNix.nixosConfigurations.\$(hostname)'';
  in super.runCommand "nixos-option" { buildInputs = [ super.makeWrapper ]; } ''
    makeWrapper ${super.nixos-option}/bin/nixos-option $out/bin/nixos-option \
      --add-flags --config_expr \
      --add-flags "\"${prefix}.config\"" \
      --add-flags --options_expr \
      --add-flags "\"${prefix}.options\""
  '';
  python3 = super.python3.override {
    packageOverrides = python-self: python-super: {
      pysonybraviapsk = python3Packages.callPackage ./pkgs/pysonybraviapsk { };
    };
  };
  python3Packages = python3.pkgs;
  yabai = super.callPackage ./pkgs/yabai { };
}
