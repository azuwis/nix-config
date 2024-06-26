{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.zsh-ssh-agent;
in
{
  options.my.zsh-ssh-agent = {
    enable = mkEnableOption "zsh-ssh-agent";
  };

  config = mkIf cfg.enable {
    programs.zsh.initExtra = ''
      # ssh-agent
      start_ssh_agent() {
        local socket="$HOME/.ssh/ssh-agent.socket"
        if [ "$SSH_AUTH_SOCK" != "$socket" ]
        then
          if [ -e "$socket" ]
          then
            export SSH_AUTH_SOCK="$socket"
            local code output
            output="$(ssh-add -l 2>/dev/null)"
            code="$?"
            if [[ "$code" -eq 0 || ( "$code" -eq 1 && "$output" = "The agent has no identities." ) ]]
            then
              :
            else
              rm "$socket"
              eval "$(ssh-agent -P "" -s -a "$socket")"
            fi
          else
            eval "$(ssh-agent -P "" -s -a "$socket")"
          fi
        fi
      }
      start_ssh_agent
      unfunction start_ssh_agent
    '';
  };
}
