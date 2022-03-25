self: super: {
  # pkgs
  anime4k = super.callPackage ./pkgs/anime4k { };
  emacsMac = (super.emacs.override { srcRepo = true; nativeComp = false; }).overrideAttrs (
    o: rec {
      version = "unstable-2022-03-12";
      src = super.fetchgit {
        url = "https://github.com/emacs-mirror/emacs.git";
        rev = "5ba9c8c364f652221a0ac9ed918a831e122581db"; # tags/emacs-2*
        sha256 = "0gh2qqcsmjych3xazq5n6s430yfnc5k1hmc7vin6c2scnlswlbz0";
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
  jetbrains-mono-nerdfont = super.callPackage ./pkgs/nerdfonts { font = "JetBrainsMono/Ligatures"; };
  kitty = super.kitty.overrideAttrs (
    o: rec {
      patches = o.patches ++ super.lib.optionals super.stdenv.isDarwin [ ./pkgs/kitty/darwin.patch ];
    }
  );
  legacyfox = super.callPackage ./pkgs/legacyfox { };
  nibar = super.callPackage ./pkgs/nibar { };
  nixos-option = let
    flake-compact = super.fetchFromGitHub {
      owner = "edolstra";
      repo = "flake-compat";
      rev = "12c64ca55c1014cdc1b16ed5a804aa8576601ff2";
      sha256 = "sha256-hY8g6H2KFL8ownSiFeMOjwPC8P0ueXpCVEbxgda3pko=";
    };
    prefix = ''(import ${flake-compact} { src = /etc/nixos; }).defaultNix.nixosConfigurations.\$(hostname)'';
  in super.runCommandNoCC "nixos-option" { buildInputs = [ super.makeWrapper ]; } ''
    makeWrapper ${super.nixos-option}/bin/nixos-option $out/bin/nixos-option \
      --add-flags --config_expr \
      --add-flags "\"${prefix}.config\"" \
      --add-flags --options_expr \
      --add-flags "\"${prefix}.options\""
  '';
  redsocks2 = super.callPackage ./pkgs/redsocks2 { };
  rime-idvel = super.callPackage ./pkgs/rime-idvel { };
  scripts = super.callPackage ./pkgs/scripts { };
  sf-symbols = self.sf-symbols-minimal;
  sf-symbols-app = super.callPackage ./pkgs/sf-symbols { app = true; fonts = false; };
  sf-symbols-full = super.callPackage ./pkgs/sf-symbols { full = true; };
  sf-symbols-minimal = super.callPackage ./pkgs/sf-symbols { };
  # sketchybar = super.callPackage ./pkgs/sketchybar {
  #   inherit (super.darwin.apple_sdk.frameworks) Carbon Cocoa SkyLight;
  # };
  torrent-ratio = super.callPackage ./pkgs/torrent-ratio { };
  yabai = let
    replace = {
      "aarch64-darwin" = "--replace '-arch x86_64' ''";
      "x86_64-darwin" = "--replace '-arch arm64e' '' --replace '-arch arm64' ''";
    }.${super.pkgs.stdenv.hostPlatform.system};
  in super.yabai.overrideAttrs(
    o: rec {
      version = "4.0.0";
      src = super.fetchFromGitHub {
        owner = "koekeishiya";
        repo = "yabai";
        rev = "v${version}";
        sha256 = "sha256-rllgvj9JxyYar/DTtMn5QNeBTdGkfwqDr7WT3MvHBGI=";
      };
      prePatch = ''
        substituteInPlace makefile ${replace};
      '';
      buildPhase = ''
        PATH=/usr/bin:/bin /usr/bin/make install
      '';
    }
  );
}
