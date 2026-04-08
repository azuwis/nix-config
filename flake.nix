{
  outputs =
    _:
    let
      lib = import ./lib;
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
            pkgs = import ./pkgs { inherit system; };
          }
        );
    in
    import ./flakes
    // {
      devShells = eachSystem ({ pkgs, ... }: import ./shell.nix { inherit pkgs; });
      apps = eachSystem (
        { pkgs, ... }:
        builtins.mapAttrs (name: drv: {
          type = "app";
          program = lib.getExe drv;
        }) (import ./apps { inherit pkgs; })
      );
      packages = eachSystem (
        { pkgs, ... }:
        let
          overlayAttrs = lib.composeManyExtensions (import ./overlays) null null;
          drvAttrs = lib.filterAttrs (name: _: lib.isDerivation pkgs.${name}) overlayAttrs;
        in
        builtins.mapAttrs (name: _: pkgs.${name}) drvAttrs
      );
    };
}
