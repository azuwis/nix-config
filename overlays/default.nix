# https://discourse.nixos.org/t/in-overlays-when-to-use-self-vs-super/2968/12

self: super: {
  # pkgs
  # cemu = super.cemu.overrideAttrs (old: {
  #   postPatch = (old.postPatch or "") + ''
  #     sed -i '/\/\/ already connected\?/,+2 d' src/input/api/DSU/DSUControllerProvider.cpp
  #   '';
  # });
  jetbrains-mono-nerdfont = self.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
  sf-symbols-app = self.callPackage ../pkgs/by-name/sf/sf-symbols/package.nix {
    app = true;
    fonts = false;
  };
  sf-symbols-full = self.callPackage ../pkgs/by-name/sf/sf-symbols/package.nix { full = true; };

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
  #         substituteInPlace render/gles2/renderer.c --replace-fail "glFlush();" "glFinish();"
  #       '';
  #   });
  # };
  # yabai = self.callPackage ../pkgs/yabai { };
}
