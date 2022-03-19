self: super: {
  # pkgs
  anime4k = super.callPackage ./pkgs/anime4k { };
  emacsMac = (super.emacs.override { srcRepo = true; nativeComp = false; }).overrideAttrs (
    o: rec {
      version = "unstable-2022-01-08";
      src = super.fetchgit {
        url = "https://github.com/emacs-mirror/emacs.git";
        rev = "d193801f59822554d28e497da146d982f5ab7995"; # tags/emacs-2*
        sha256 = "04jd742ys4saa0jxs6carn8wsidm38m7pdcryc42rb7y1a9l3zyf";
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
  legacyfox = super.callPackage ./pkgs/legacyfox { };
  nibar = super.callPackage ./pkgs/nibar { };
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
