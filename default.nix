{ ... }@args:

# nixpkgs/maintainers/scripts/update.py and nix-update expect a nixpkgs-like repo.
# When called with `--commit`, update.py will create a new git worktree, and run
# updateScript (e.g. nix-update) in the git worktree root, so the root dir needs
# to provide nixpkgs-like attrs.
# https://discourse.nixos.org/t/25274
# https://github.com/jtojnar/nixfiles/blob/master/default.nix
import ./pkgs args // import ./flakes
