{ config }:

let
  lib = import ./default.nix;

  toPathStringPart = n: if builtins.isString n then lib.strings.escapeNixIdentifier n else "*";

  toPathString = path: lib.concatMapStringsSep "." toPathStringPart path;

  force =
    depth: value:
    if depth <= 0 then
      value
    else if builtins.isAttrs value && !(value ? outPath && value ? drvPath) then
      builtins.seq (builtins.foldl' (
        acc: name:
        let
          child = value.${name} or null;
        in
        if child != null then (builtins.tryEval (force (depth - 1) child)).value else acc
      ) null (builtins.attrNames value)) value
    else if builtins.isList value then
      builtins.seq (builtins.foldl' (acc: e: (builtins.tryEval (force depth e)).value) null value) value
    else
      value;

  trace =
    path: value:
    if builtins.length path > 15 then
      value
    else if builtins.isAttrs value && !(value ? outPath && value ? drvPath) then
      lib.mapAttrs (name: trace (path ++ [ name ])) value
    else if builtins.isList value then
      lib.imap (i: trace (path ++ [ (i - 1) ])) value
    else if builtins.isFunction value then
      value
    else
      let
        str =
          if value ? outPath && value ? drvPath then "<derivation>" else lib.generators.toPretty { } value;
      in
      builtins.trace "CONFIGDIFF${
        builtins.toJSON [
          (toPathString path)
          str
        ]
      }" value;

  skip = [
    "_module"
    "assertions"
    "warnings"
    "meta"
    "passthru"
    "image"
  ];
in

builtins.foldl' (
  acc: name:
  if builtins.elem name skip then
    acc
  else
    let
      val = config.${name} or null;
    in
    if val != null && !(val ? outPath && val ? drvPath) && builtins.isAttrs val then
      (builtins.tryEval (force 10 (trace [ name ] val))).value
    else
      acc
) null (builtins.attrNames config)
