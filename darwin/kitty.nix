{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib then

{
  programs.kitty.enable = true;
  programs.kitty.darwinLaunchOptions = [
    "--single-instance"
    "--directory=~"
  ];
  programs.kitty.environment = {
    TERMINFO_DIRS = "${pkgs.kitty.terminfo.outPath}/share/terminfo";
  };
  programs.kitty.font.name = "JetBrainsMono Nerd Font";
  programs.kitty.font.size = 15;
  programs.kitty.settings = {
    # background_opacity = "0.85";
    copy_on_select = true;
    cursor_blink_interval = 0;
    editor = "vim";
    hide_window_decorations = true;
    scrollback_pager_history_size = 1;
    update_check_interval = 0;
  };
  programs.kitty.theme = "Nord";
  programs.kitty.extraConfig = ''
    # symbol_map U+E5FA-U+E62B,U+E700-U+E7C5,U+F000-U+F2E0,U+E200-U+E2A9,U+F500-U+FD46,U+E300-U+E3EB,U+F400-U+F4A8,U+2665,U+26A1,U+F27C,U+E0A3,U+E0B4-U+E0C8,U+E0CA,U+E0CC-U+E0D2,U+E0D4,U+23FB-U+23FE,U+2B58,U+F300-U+F313,U+E000-U+E00D JetBrainsMono Nerd Font
    # symbol_map U+100000-U+10FFFF SF Pro
  '';
  programs.zsh.initExtra = ''
    # kitty shell integration
    if [[ -n $KITTY_INSTALLATION_DIR ]]; then
      export KITTY_SHELL_INTEGRATION="enabled"
      autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
      kitty-integration
      unfunction kitty-integration
    fi
  '';
}

else

{
  environment.etc."sudoers.d/kitty".text = ''
    Defaults env_keep += "TERMINFO_DIRS"
  '';
}
