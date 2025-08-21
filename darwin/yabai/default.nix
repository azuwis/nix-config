{
  config,
  lib,
  pkgs,
  ...
}:

{
  # csrutil enable --without fs --without debug --without nvram
  # nvram boot-args=-arm64e_preview_abi
  environment.etc."sudoers.d/yabai".text = ''
    ${config.my.user} ALL = (root) NOPASSWD: ${config.services.yabai.package}/bin/yabai --load-sa
  '';

  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    config = {
      auto_balance = "on";
      layout = "bsp";
      mouse_modifier = "alt";
      # top_padding = 0;
      # bottom_padding = 2;
      # left_padding = 2;
      # right_padding = 2;
      window_gap = 2;
      window_shadow = "float";
    };
    # yabai -m query --windows --space
    # https://github.com/koekeishiya/yabai/issues/1297#issuecomment-1318403190
    # launchctl unload -F /System/Library/LaunchAgents/com.apple.WindowManager.plist
    extraConfig = ''
      gap=6
      yabai -m config top_padding "$gap"
      yabai -m config bottom_padding "$gap"
      yabai -m config left_padding "$gap"
      yabai -m config right_padding "$gap"
      yabai -m config window_gap "$gap"

      yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
      # yabai -m signal --add event=system_woke action="pkill -x skhd"

      yabai -m rule --add app="^(Digital Color Meter|Finder|System Information|System Preferences|System Settings|Ryujinx|mpv)$" manage=off
      yabai -m rule --add app="^[Aa]lacritty$" title="^Fzf$" manage=off
      yabai -m rule --add app="^[Kk]itty$" title="^Fzf$" manage=off grid=6:6:2:2:2:1
      yabai -m rule --add app="^(Firefox|Google Chrome|Safari)$" space=2
      yabai -m rule --add app="^Mail$" space=3
      yabai -m rule --add app="^网易POPO$" manage=off space=5

      yabai -m space 5 --layout float

      wait4path /etc/sudoers.d/yabai
      sudo yabai --load-sa
    '';
  };

  launchd.user.agents.yabai.serviceConfig.EnvironmentVariables.PATH =
    lib.mkForce "${config.services.yabai.package}/bin:${config.my.systemPath}";

  # launchd.user.agents.yabai.serviceConfig = {
  #   StandardErrorPath = "/tmp/yabai.log";
  #   StandardOutPath = "/tmp/yabai.log";
  # };

  # https://github.com/koekeishiya/yabai#requirements-and-caveats
  system.defaults.CustomUserPreferences = {
    "com.apple.dock" = {
      # Automatically rearrange Spaces based on most recent use -> [ ]
      mru-spaces = 0;
    };
    "com.apple.WindowManager" = {
      # Show Items -> On Desktop -> [x]
      StandardHideDesktopIcons = 0;
      # Click wallpaper to reveal Desktop -> Only in Stage Manager
      EnableStandardClickToShowDesktop = 0;
    };
  };

  system.activationScripts.preActivation.text = ''
    ${pkgs.sqlite}/bin/sqlite3 '/Library/Application Support/com.apple.TCC/TCC.db' \
      "INSERT or REPLACE INTO access(service,client,client_type,auth_value,auth_reason,auth_version) VALUES('kTCCServiceAccessibility','${config.services.yabai.package}/bin/yabai',1,2,4,1);"
  '';
  system.activationScripts.postActivation.text = ''
    ${pkgs.sqlite}/bin/sqlite3 '/Library/Application Support/com.apple.TCC/TCC.db' \
      "DELETE from access where client_type = 1 and client != '${config.services.yabai.package}/bin/yabai' and client like '%/bin/yabai';"
  '';
}
