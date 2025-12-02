# https://nixos.org/manual/nixpkgs/stable/#sec-config-options-reference
# Can be use as `~/.config/nixpkgs/config.nix`.
# Also used by `common/nixpkgs/default.nix` `pkgs/default.nix`

{
  allowAliases = false;
  allowUnfree = true;
  android_sdk.accept_license = true;
}
