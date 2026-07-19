{
  lib,
  fetchurl,
}:

let
  sources = lib.importJSON ./sources.json;
  inherit (sources) version;

  variants = lib.genAttrs (builtins.attrNames sources.variants) (
    variant:
    fetchurl {
      url = "https://github.com/lotem/rime-octagram-data/releases/download/${version}/${variant}.gram";
      sha256 = sources.variants.${variant} or (throw "Unknown variant: ${variant}");
    }
    // {
      meta = {
        description = "Rime octagram data (${variant})";
        homepage = "https://github.com/lotem/rime-octagram-data";
        license = lib.licenses.lgpl3Only;
        position = toString ./package.nix;
      };
    }
  );
in

variants.zh-hans-t-essay-bgw
// variants
// {
  name = "rime-octagram-data";
  updateScript = ./update.sh;
}
