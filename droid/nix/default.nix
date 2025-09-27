{
  config,
  lib,
  pkgs,
  ...
}:

# nixpkgs/pkgs/pkgs-lib/formats.nix
let
  inherit (lib)
    boolToString
    concatStringsSep
    escape
    hasPrefix
    isBool
    isDerivation
    isFloat
    isInt
    isString
    filterAttrs
    mapAttrsToList
    strings
    toPretty
    ;
  cfg = config.nix;

  mkValueString =
    v:
    if v == null then
      ""
    else if isInt v then
      toString v
    else if isBool v then
      boolToString v
    else if isFloat v then
      strings.floatToString v
    else if isDerivation v then
      toString v
    else if builtins.isPath v then
      toString v
    else if isString v then
      v
    else if strings.isConvertibleWithToString v then
      toString v
    else
      abort "The nix conf value: ${toPretty { } v} can not be encoded";

  mkKeyValue = k: v: "${escape [ "=" ] k} = ${mkValueString v}";

  mkKeyValuePairs = attrs: concatStringsSep "\n" (mapAttrsToList mkKeyValue attrs);

  isExtra = key: hasPrefix "extra-" key;
in

{
  options.nix = {
    settings = lib.mkOption { };
  };

  config = {
    nix.extraOptions = ''
      ${mkKeyValuePairs (filterAttrs (key: _: !(isExtra key)) cfg.settings)}
      ${mkKeyValuePairs (filterAttrs (key: _: isExtra key) cfg.settings)}
    '';
  };
}
