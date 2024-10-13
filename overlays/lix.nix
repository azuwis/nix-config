final: prev: {
  agenix = prev.agenix.override { nix = final.lix; };
  nix-direnv = prev.nix-direnv.override { nix = final.lix; };
  nixos-option = prev.nixos-option.override { nix = final.lix; };
}
