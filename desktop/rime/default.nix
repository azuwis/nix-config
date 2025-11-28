{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.programs.rime;
in
{
  options.programs.rime = {
    enable = mkEnableOption "rime";

    dir = mkOption {
      type = types.str;
      default =
        {
          # /Library/Input\ Methods/Squirrel.app/Contents/SharedSupport
          darwin = "Library/Rime";
          linux = ".local/share/fcitx5/rime";
        }
        .${pkgs.stdenv.hostPlatform.parsed.kernel.name};
    };

    # deploy = mkOption {
    #   type = types.str;
    #   default =
    #     {
    #       darwin = "'/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel' --reload";
    #       linux = "fcitx-remote -r";
    #     }
    #     .${pkgs.stdenv.hostPlatform.parsed.kernel.name};
    # };
  };

  config = mkIf cfg.enable {
    home.file."${cfg.dir}/cn_dicts".source = "${pkgs.rime-ice}/share/rime-data/cn_dicts";
    home.file."${cfg.dir}/rime_ice.dict.yaml".source = pkgs.runCommand "rime_ice.dict.yaml" { } ''
      sed '/^\.\.\.$/q' ${pkgs.rime-ice}/share/rime-data/rime_ice.dict.yaml > $out
    '';

    home.file."${cfg.dir}/default.custom.yaml".text = ''
      patch:
        switcher/hotkeys:
          - Control+grave
        schema_list:
          - schema: csp
          - schema: luna_pinyin
    '';

    home.file."${cfg.dir}/csp.schema.yaml".source = ./csp.schema.yaml;
    home.file."${cfg.dir}/csp_custom_phrase.txt".source = ./csp_custom_phrase.txt;

    home.file."${cfg.dir}/grammar.yaml".source = pkgs.fetchurl {
      url = "https://github.com/lotem/rime-octagram-data/raw/master/grammar.yaml";
      sha256 = "0aa14rvypnja38dm15hpq34xwvf06al6am9hxls6c4683ppyk355";
    };

    home.file."${cfg.dir}/zh-hans-t-essay-bgw.gram".source = pkgs.fetchurl {
      url = "https://github.com/lotem/rime-octagram-data/raw/hans/zh-hans-t-essay-bgw.gram";
      sha256 = "0ygcpbhp00lb5ghi56kpxl1mg52i7hdlrznm2wkdq8g3hjxyxfqi";
    };

    # https://github.com/rime/librime/issues/972
    # patch:
    #   punctuator/digit_separators: ",.:" # default value, set "" to disable
    #   punctuator/digit_separator_action: "" # default not set, set "commit" to auto commit
    home.file."${cfg.dir}/luna_pinyin.custom.yaml".text = ''
      patch:
        __include: grammar:/hans
        translator/dictionary: rime_ice
    '';

    home.file."${cfg.dir}/squirrel.custom.yaml".text =
      lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
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
  };
}
