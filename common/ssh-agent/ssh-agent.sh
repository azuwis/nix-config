# ssh-agent
start_ssh_agent() {
  socket="$HOME/.ssh/ssh-agent.socket"
  if [ "$SSH_AUTH_SOCK" != "$socket" ]; then
    if [ -e "$socket" ]; then
      export SSH_AUTH_SOCK="$socket"
      output="$(ssh-add -l 2>/dev/null)"
      code="$?"
      if [ "$code" -eq 0 ] || { [ "$code" -eq 1 ] && [ "$output" = "The agent has no identities." ]; }; then
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
unset -f start_ssh_agent
