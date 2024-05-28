# https://discourse.nixos.org/t/in-overlays-when-to-use-self-vs-super/2968/12

self: super: {
  # pkgs
  # cemu = super.cemu.overrideAttrs (old: {
  #   postPatch = (old.postPatch or "") + ''
  #     sed -i '/\/\/ already connected\?/,+2 d' src/input/api/DSU/DSUControllerProvider.cpp
  #   '';
  # });
  jetbrains-mono-nerdfont = self.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
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
      rev = "fee54a9d765d6121c831cdaac90aff490824231f";
      sha256 = "sha256-iJ5DFfbtkBVHL35lsX1OYhqN+DG7/9g5D2iwN4marjY=";
    };
    patches = [ ../patches/moonlight.diff ];
  });
  sf-symbols-app = self.callPackage ../pkgs/by-name/sf/sf-symbols/package.nix {
    app = true;
    fonts = false;
  };
  sf-symbols-full = self.callPackage ../pkgs/by-name/sf/sf-symbols/package.nix { full = true; };
  sunshine-git = self.sunshine.overrideAttrs (old: {
    pname = "sunshine-git";
    src = old.src.override {
      rev = "c5bf78176e0bb70c1dcb43ef062afff3ce3da2e2";
      sha256 = "sha256-T2kKv28DHIpnUUVwYACYvYflbwdok7bEcMP/zp28SRA=";
    };
  });

  # override
  fcitx5-configtool = self.writeShellScriptBin "fcitx5-config-qt" ''
    echo "fcitx-config-qt dummy command"
  '';
  nixos-option =
    let
      prefix = ''(builtins.getFlake \\\"/etc/nixos\\\").nixosConfigurations.\$(hostname)'';
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
  #     pysonybraviapsk = self.python3.pkgs.callPackage ../pkgs/pysonybraviapsk { };
  #   };
  # };
  # python3Packages = self.python3.pkgs;
  # sway-unwrapped = super.sway-unwrapped.override {
  #   wlroots = self.wlroots_0_16.overrideAttrs (old: {
  #     postPatch =
  #       (old.postPatch or "") + ''
  #         substituteInPlace render/gles2/renderer.c --replace "glFlush();" "glFinish();"
  #       '';
  #   });
  # };
  # Remove when they're in nixpkgs
  vimPlugins = super.vimPlugins // {
    ts-comments-nvim = self.vimUtils.buildVimPlugin {
      pname = "ts-comments.nvim";
      version = "2024-05-26";
      src = self.fetchFromGitHub {
        owner = "folke";
        repo = "ts-comments.nvim";
        rev = "f7ded340b4c6b317593b867838bf7ace354a67d4";
        sha256 = "1pajs8xsx65d5wzr6j98b0am52np2qijk8k7nc6dg6ibjfvwssyr";
      };
      meta.homepage = "https://github.com/folke/ts-comments.nvim/";
    };
  };
  # yabai = self.callPackage ../pkgs/yabai { };
}
