{ inputs, ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      devshells.default = {
        packages = with pkgs; [ nix-diff ];
      };
    };
}
