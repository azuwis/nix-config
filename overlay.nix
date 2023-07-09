self: super: rec {
  # pkgs
  anime4k = super.callPackage ./pkgs/anime4k { };
  dualsensectl = super.callPackage ./pkgs/dualsensectl { };
  evdevhook = super.callPackage ./pkgs/evdevhook { };
  jetbrains-mono-nerdfont = super.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
  legacyfox = super.callPackage ./pkgs/legacyfox { };
  moonlight-cemuhook = super.moonlight-qt.overrideAttrs (o: {
    pname = "moonlight-cemuhook";
    src = super.fetchFromGitHub {
      owner = "azuwis";
      repo = "moonlight-qt";
      rev = "4d001f122cb200dc2d668e74a03f22149382b993";
      sha256 = "sha256-QDvk8PYL92lKEzSKNsqVk23Yy7LJdCElEfek62rlIkA=";
      fetchSubmodules = true;
    };
  });
  nibar = super.callPackage ./pkgs/nibar { };
  redsocks2 = super.callPackage ./pkgs/redsocks2 { };
  rime-ice = super.callPackage ./pkgs/rime-ice { };
  scripts = super.callPackage ./pkgs/scripts { };
  sf-symbols = self.sf-symbols-minimal;
  sf-symbols-app = super.callPackage ./pkgs/sf-symbols { app = true; fonts = false; };
  sf-symbols-full = super.callPackage ./pkgs/sf-symbols { full = true; };
  sf-symbols-minimal = super.callPackage ./pkgs/sf-symbols { };
  steam-devices = super.callPackage ./pkgs/steam-devices { };
  sunshine-git = super.sunshine.overrideAttrs (o: {
    src = super.fetchFromGitHub {
      owner = "LizardByte";
      repo = "Sunshine";
      rev = "c5bf78176e0bb70c1dcb43ef062afff3ce3da2e2";
      sha256 = "sha256-T2kKv28DHIpnUUVwYACYvYflbwdok7bEcMP/zp28SRA=";
      fetchSubmodules = true;
    };
  });
  torrent-ratio = super.callPackage ./pkgs/torrent-ratio { };

  # override
  fcitx5-configtool = null;
  nixos-option =
    let
      flake-compact = super.fetchFromGitHub {
        owner = "edolstra";
        repo = "flake-compat";
        rev = "12c64ca55c1014cdc1b16ed5a804aa8576601ff2";
        sha256 = "sha256-hY8g6H2KFL8ownSiFeMOjwPC8P0ueXpCVEbxgda3pko=";
      };
      prefix = ''(import ${flake-compact} { src = /etc/nixos; }).defaultNix.nixosConfigurations.\$(hostname)'';
    in
    super.runCommand "nixos-option" { buildInputs = [ super.makeWrapper ]; } ''
      makeWrapper ${super.nixos-option}/bin/nixos-option $out/bin/nixos-option \
        --add-flags --config_expr \
        --add-flags "\"${prefix}.config\"" \
        --add-flags --options_expr \
        --add-flags "\"${prefix}.options\""
    '';
  python3 = super.python3.override {
    packageOverrides = python-self: python-super: {
      dsdrv-cemuhook = python3.pkgs.callPackage ./pkgs/dsdrv-cemuhook { };
      pysonybraviapsk = python3.pkgs.callPackage ./pkgs/pysonybraviapsk { };
      subfinder = python3.pkgs.callPackage ./pkgs/subfinder { };
    };
  };
  python3Packages = python3.pkgs;
  # sketchybar = super.callPackage ./pkgs/sketchybar {
  #   inherit (super.darwin.apple_sdk.frameworks) Carbon Cocoa SkyLight;
  # };
  # trigger-control = super.callPackage ./pkgs/trigger-control { };
  # uxplay = super.callPackage ./pkgs/uxplay { };
  # yabai = super.callPackage ./pkgs/yabai { };
}
