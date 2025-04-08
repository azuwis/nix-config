{
  outputs =
    _:
    let
      lib = import ../lib;
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      eachSystem =
        f:
        lib.genAttrs systems (
          system:
          f rec {
            inherit system;
            pkgs = import ../pkgs { inherit system; };
          }
        );
    in
    import ./default.nix
    // {
      devShells = eachSystem ({ pkgs, ... }: import ../shell.nix { inherit pkgs; });
      packages = eachSystem ({ pkgs, ... }: import ../apps { inherit pkgs; });
    };
}
