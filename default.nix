{ ... }@args:

# nix-update expects to import a nixpkgs-like package set, and it can run
# inside ./pkgs, where pkgs/default.nix is already one. But when called with
# `--commit`, update.py imports `./.` in a new git worktree and runs
# updateScript (e.g. nix-update) there, so the repo root needs to provide
# nixpkgs-like attrs.
# https://github.com/jtojnar/nixfiles/blob/master/default.nix
import ./pkgs args // import ./flakes
