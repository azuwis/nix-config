{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  nix-index-database = import inputs.nix-index-database.outPath { inherit pkgs; };

  # Wrap nix-locate to use full database, nix-locate-small to use small database
  nix-index = pkgs.runCommand "nix-index" { buildInputs = [ pkgs.makeWrapper ]; } ''
    mkdir -p $out/etc/profile.d $out/share/misc/full $out/share/misc/small
    ln -s ${nix-index-database.nix-index-database} $out/share/misc/full/files
    ln -s ${nix-index-database.nix-index-small-database} $out/share/misc/small/files
    makeWrapper ${pkgs.nix-index}/bin/nix-locate $out/bin/nix-locate \
      --set NIX_INDEX_DATABASE $out/share/misc/full
    makeWrapper ${pkgs.nix-index}/bin/nix-locate $out/bin/nix-locate-small \
      --set NIX_INDEX_DATABASE $out/share/misc/small
    substitute ${pkgs.nix-index}/etc/profile.d/command-not-found.sh $out/etc/profile.d/command-not-found.sh \
      --replace-fail "${pkgs.nix-index-unwrapped}/bin/nix-locate" "$out/bin/nix-locate-small"
  '';
in

{
  config = lib.mkIf config.programs.nix-index.enable {
    programs.command-not-found.enable = false;
    programs.nix-index.package = nix-index;
  };
}
