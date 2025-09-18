{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = [ pkgs.kitty ];

  environment.etc."sudoers.d/kitty".text = ''
    Defaults env_keep += "TERMINFO_DIRS"
  '';

  # Use `kitten choose_fonts` to get font names
  environment.etc."xdg/kitty/kitty.conf".text = ''
    copy_on_select yes
    cursor_blink_interval 0
    editor vim
    env SHELL=/run/current-system/sw/bin/zsh
    font_family JetBrainsMono Nerd Font Mono
    font_size 15
    hide_window_decorations titlebar-only
    include ${pkgs.kitty-themes}/share/kitty-themes/themes/Nord.conf
    macos_option_as_alt yes
    scrollback_pager_history_size 1
    shell /run/current-system/sw/bin/zsh -l -i
    shell_integration no-rc
    update_check_interval 0
  '';

  # environment.etc."xdg/kitty/macos-launch-services-cmdline".text = ''
  #   --single-instance --directory=~
  # '';
}
