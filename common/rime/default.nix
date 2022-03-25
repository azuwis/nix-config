{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib then

let
  rime = {
    # /Library/Input\ Methods/Squirrel.app/Contents/SharedSupport
    darwin = {
      dir = "Library/Rime";
      deploy = "'/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel' --reload";
    };
    linux = {
      dir = ".local/share/fcitx5/rime";
      deploy = "fcitx-remote -r";
    };
  }.${pkgs.stdenv.hostPlatform.parsed.kernel.name};
in

{
  home.file."${rime.dir}" = {
    source = pkgs.rime-idvel;
    recursive = true;
    onChange = rime.deploy;
  };
  home.file."${rime.dir}/default.custom.yaml".text = ''
    patch:
      switcher/hotkeys:
        - Control+grave
      schema_list:
        - schema: csp
        - schema: luna_pinyin
  '';
  home.file."${rime.dir}/csp.schema.yaml".source = ./csp.schema.yaml;
  home.file."${rime.dir}/grammar.yaml".source = pkgs.fetchurl {
    url = "https://github.com/lotem/rime-octagram-data/raw/master/grammar.yaml";
    sha256 = "0aa14rvypnja38dm15hpq34xwvf06al6am9hxls6c4683ppyk355";
  };
  home.file."${rime.dir}/zh-hans-t-essay-bgw.gramhans".source = pkgs.fetchurl {
    url = "https://github.com/lotem/rime-octagram-data/raw/hans/zh-hans-t-essay-bgw.gram";
    sha256 = "0ygcpbhp00lb5ghi56kpxl1mg52i7hdlrznm2wkdq8g3hjxyxfqi";
  };
  home.file."${rime.dir}/luna_pinyin.custom.yaml".text = ''
    patch:
      __include: grammar:/hans
      translator/dictionary: pinyin_simp
  '';
  home.file."${rime.dir}/squirrel.custom.yaml".text = lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
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
