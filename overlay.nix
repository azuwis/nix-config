# https://discourse.nixos.org/t/in-overlays-when-to-use-self-vs-super/2968/12

self: super: {
  # pkgs
  anime4k = self.callPackage ./pkgs/anime4k { };
  # cemu = super.cemu.overrideAttrs (old: {
  #   postPatch = (old.postPatch or "") + ''
  #     sed -i '/\/\/ already connected\?/,+2 d' src/input/api/DSU/DSUControllerProvider.cpp
  #   '';
  # });
  dsdrv-cemuhook = self.callPackage ./pkgs/dsdrv-cemuhook { };
  dualsensectl = self.callPackage ./pkgs/dualsensectl { };
  evdevhook = self.callPackage ./pkgs/evdevhook { };
  evdevhook2 = self.callPackage ./pkgs/evdevhook2 { };
  jetbrains-mono-nerdfont = self.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
  jslisten = self.callPackage ./pkgs/jslisten { };
  legacyfox = self.callPackage ./pkgs/legacyfox { };
  moonlight-cemuhook = self.moonlight-qt.overrideAttrs (old: {
    pname = "moonlight-cemuhook";
    src = old.src.override {
      owner = "azuwis";
      rev = "4d001f122cb200dc2d668e74a03f22149382b993";
      sha256 = "sha256-QDvk8PYL92lKEzSKNsqVk23Yy7LJdCElEfek62rlIkA=";
    };
  });
  moonlight-git = self.moonlight-qt.overrideAttrs (old: {
    pname = "moonlight-git";
    src = old.src.override {
      rev = "e287ebcded4ebbd2ddaff5b8ceade3e09946f864";
      sha256 = "sha256-y2lm5ZU3tIl1qrmOiF5FVt8Nw8VrNPzLOz5ji0vR2RQ=";
    };
    patches = [ ];
  });
  nibar = self.callPackage ./pkgs/nibar { };
  redsocks2 = self.callPackage ./pkgs/redsocks2 { };
  rime-ice = self.callPackage ./pkgs/rime-ice { };
  scripts = self.callPackage ./pkgs/scripts { };
  sf-symbols = self.sf-symbols-minimal;
  sf-symbols-app = self.callPackage ./pkgs/sf-symbols { app = true; fonts = false; };
  sf-symbols-full = self.callPackage ./pkgs/sf-symbols { full = true; };
  sf-symbols-minimal = self.callPackage ./pkgs/sf-symbols { };
  steam-devices = self.callPackage ./pkgs/steam-devices { };
  subfinder = self.callPackage ./pkgs/subfinder { };
  sunshine-git = self.sunshine.overrideAttrs (old: {
    pname = "sunshine-git";
    src = old.src.override {
      rev = "c5bf78176e0bb70c1dcb43ef062afff3ce3da2e2";
      sha256 = "sha256-T2kKv28DHIpnUUVwYACYvYflbwdok7bEcMP/zp28SRA=";
    };
  });
  torrent-ratio = self.callPackage ./pkgs/torrent-ratio { };
  # sway-unwrapped = super.sway-unwrapped.override {
  #   wlroots = self.wlroots_0_16.overrideAttrs (old: {
  #     postPatch =
  #       (old.postPatch or "") + ''
  #         substituteInPlace render/gles2/renderer.c --replace "glFlush();" "glFinish();"
  #       '';
  #   });
  # };

  # override
  fcitx5-configtool = self.writeShellScriptBin "fcitx5-config-qt" ''
    echo "fcitx-config-qt dummy command"
  '';
  nixos-option =
    let
      flake-compact = self.fetchFromGitHub {
        owner = "edolstra";
        repo = "flake-compat";
        rev = "12c64ca55c1014cdc1b16ed5a804aa8576601ff2";
        sha256 = "sha256-hY8g6H2KFL8ownSiFeMOjwPC8P0ueXpCVEbxgda3pko=";
      };
      prefix = ''(import ${flake-compact} { src = /etc/nixos; }).defaultNix.nixosConfigurations.\$(hostname)'';
    in
    self.runCommand "nixos-option" { buildInputs = [ self.makeWrapper ]; } ''
      makeWrapper ${super.nixos-option}/bin/nixos-option $out/bin/nixos-option \
        --add-flags --config_expr \
        --add-flags "\"${prefix}.config\"" \
        --add-flags --options_expr \
        --add-flags "\"${prefix}.options\""
    '';
  # python3 = super.python3.override {
  #   packageOverrides = pyself: pysuper: {
  #     pysonybraviapsk = self.python3.pkgs.callPackage ./pkgs/pysonybraviapsk { };
  #   };
  # };
  # python3Packages = self.python3.pkgs;
  # sketchybar = self.callPackage ./pkgs/sketchybar {
  #   inherit (self.darwin.apple_sdk.frameworks) Carbon Cocoa SkyLight;
  # };
  # trigger-control = self.callPackage ./pkgs/trigger-control { };
  # uxplay = self.callPackage ./pkgs/uxplay { };
  # yabai = self.callPackage ./pkgs/yabai { };
}
