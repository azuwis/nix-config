{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib then

let
  rimeDir = {
    # /Library/Input\ Methods/Squirrel.app/Contents/SharedSupport
    Darwin = "Library/Rime";
    Linux = ".local/share/fcitx5/rime";
  }."${pkgs.stdenv.hostPlatform.uname.system}";
in

{
  home.file."${rimeDir}" = {
    source = pkgs.rime-csp;
    recursive = true;
  };
  home.file."${rimeDir}/default.custom.yaml".text = ''
    patch:
      switcher/hotkeys:
        - Control+grave
      schema_list:
        - schema: csp
        - schema: luna_pinyin
  '';
  home.file."${rimeDir}/luna_pinyin.custom.yaml".text = ''
    patch:
      __include: grammar:/hans
      translator/dictionary: pinyin_simp
  '';
  home.file."${rimeDir}/squirrel.custom.yaml".text = lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
    patch:
      app_options/io.alacritty:
        ascii_mode: true
        no_inline: true
      style/color_scheme: purity_of_form
      style/font_point: 18
      preset_color_schemes/purity_of_form/text_color: 0x333333
      preset_color_schemes/purity_of_form/back_color: 0x545554
      preset_color_schemes/purity_of_form/hilited_candidate_back_color: 0xe3e3e3
  '';
}

else

{
  homebrew.casks = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ "squirrel" ];
}
