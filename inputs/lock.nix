{
  pure ? true,
}:
let
  lockFile = import ./lock.lock;
  inputsFile = import ./inputs.nix;
in
builtins.mapAttrs (
  name: meta:
  let
    lock = lockFile.${name} or { };
    isPure = pure && lock != { };
    isType = t: meta.type == t;
    fetchGits = builtins.fetchGit (
      {
        inherit name;
      }
      // (if meta ? url then { inherit (meta) url; } else { })
      // (if meta ? rev then { inherit (meta) rev; } else { })
      // (if meta ? ref then { inherit (meta) ref; } else { })
      // (if meta ? submodules then { inherit (meta) submodules; } else { })
      // (if meta ? exportIgnore then { inherit (meta) exportIgnore; } else { })
      // (if meta ? shallow then { inherit (meta) shallow; } else { shallow = true; })
      // (if meta ? lfs then { inherit (meta) lfs; } else { })
      // (if meta ? allRefs then { inherit (meta) allRefs; } else { })
      // (if meta ? lastModified then { inherit (meta) lastModified; } else { })
      // (if meta ? revCount then { inherit (meta) revCount; } else { })
      // (if isPure then { inherit (lock) narHash; } else { })
      // (if isPure && lock ? rev then { inherit (lock) rev; } else { })
      // (if isPure && lock ? submodules then { inherit (lock) submodules; } else { })
      // (if isPure && lock ? lastModified then { inherit (lock) lastModified; } else { })
      // (if isPure && lock ? revCount then { inherit (lock) revCount; } else { })
    );
  in
  if isType "archive" then
    if isPure then
      lock
      // {
        outPath = builtins.fetchTarball {
          inherit name;
          url = meta.url + "/archive/" + lock.rev + ".tar.gz";
          sha256 = lock.narHash;
        };
      }
    else
      fetchGits
  else if isType "git" then
    if isPure then
      lock
      // {
        inherit (fetchGits) outPath;
      }
    else
      fetchGits
  else
    { }
) inputsFile
