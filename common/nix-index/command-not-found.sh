#!/usr/bin/env bash

# for bash 4
# this will be called when a command is entered
# but not found in the user’s path + environment
command_not_found_handle() {

  # taken from http://www.linuxjournal.com/content/bash-command-not-found
  # - do not run when inside Midnight Commander or within a Pipe
  if [ -n "${MC_SID-}" ] || ! [ -t 1 ]; then
    >&2 echo "$1: command not found"
    return 127
  fi

  toplevel=nixpkgs # nixpkgs should always be available even in NixOS
  cmd=$1
  attrs=$(nix-locate-small --minimal --no-group --type x --type s --whole-name --at-root "/bin/$cmd")
  len=$(echo -n "$attrs" | grep -c "^")

  case $len in
  0)
    >&2 echo "$cmd: command not found"
    ;;
  1)
    # if only 1 package provides this, then we can invoke it
    # without asking the users if they have opted in with one
    # environment variable

    # based on the ones found in command-not-found.sh:

    #   NIX_AUTO_RUN     : run the command transparently inside of
    #                      nix shell

    # these will not return 127 if they worked correctly

    if [ -n "${NIX_AUTO_RUN-}" ]; then
      if out=$(nix-build --no-out-link -A "$attrs" "<$toplevel>"); then
        shift
        "$out/bin/$cmd" "$@"
        return $?
      else
        >&2 cat <<EOF
Failed to install $toplevel.$attrs.
$cmd: command not found
EOF
      fi
    else
      >&2 cat <<EOF
The program '$cmd' is not installed. Run it once with:

  nix-shell -p ${attrs%.out} --run '$cmd ...'
EOF
    fi
    ;;
  *)
    >&2 cat <<EOF
The program '$cmd' is not installed. It is provided by several packages. Run it once with:

EOF

    while read -r attr; do
      >&2 echo "  nix-shell -p ${attr%.out} --run '$cmd ...'"
    done <<<"$attrs"
    ;;
  esac

  return 127 # command not found should always exit with 127
}

# for zsh...
# we just pass it to the bash handler above
# apparently they work identically
command_not_found_handler() {
  command_not_found_handle "$@"
}
