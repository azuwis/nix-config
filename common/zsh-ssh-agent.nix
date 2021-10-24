{ config, lib, pkgs, ... }:

{
  programs.zsh.initExtra = ''
    start_ssh_agent() {
      if [ -z "$SSH_AUTH_SOCK" ]
      then
        local socket="$HOME/.ssh/ssh-agent.socket"
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
            eval "$(ssh-agent -s -a "$socket")"
          fi
        else
          eval "$(ssh-agent -s -a "$socket")"
        fi
      fi
    }
    start_ssh_agent
    unfunction start_ssh_agent
  '';
}
