# https://discourse.nixos.org/t/in-overlays-when-to-use-self-vs-super/2968/12

self: super: {
  # pkgs
  # cemu = super.cemu.overrideAttrs (old: {
  #   postPatch = (old.postPatch or "") + ''
  #     sed -i '/\/\/ already connected\?/,+2 d' src/input/api/DSU/DSUControllerProvider.cpp
  #   '';
  # });
  jetbrains-mono-nerdfont = self.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
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
      rev = "4855e091d2eae99747b326e610070858e0ef312e";
      sha256 = "sha256-4/0cX0RksAW8BI5ADfAhZiGH3RxReyegKoOwpxD7AII=";
    };
    buildInputs = old.buildInputs ++ [ self.nodejs ];
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
  # yabai = self.callPackage ../pkgs/yabai { };
}
