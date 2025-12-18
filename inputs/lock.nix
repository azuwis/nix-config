{
  update ? false,
  targets ? { },
}:
let
  lockFile = import ./lock.lock;
  inputsFile = import ./inputs.nix;
in
builtins.mapAttrs (
  name: meta:
  let
    lock = lockFile.${name} or { };
    isPure = (targets.${name} or update) == false && lock != { };
    isType = t: meta.type == t;
    fetchGitArgs = {
      inherit name;
      shallow = true;
    }
    // removeAttrs meta [ "type" ]
    // (
      if isPure then
        removeAttrs lock [
          "lastModifiedDate"
          "outPath"
          "shortRev"
        ]
      else
        { }
    );
    fetchGits =
      builtins.trace "fetchGit ${builtins.toJSON fetchGitArgs}" builtins.fetchGit
        fetchGitArgs;
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
        # Hack here, builtins.fetchGit always fetch even if narHash provided,
        # use fetchTarball to produce the outPath if already in nix store
        # https://github.com/nikstur/lon/pull/3#issuecomment-2797643718
        outPath =
          if builtins.pathExists lock.outPath then
            builtins.fetchTarball {
              inherit name;
              url = "";
              sha256 = lock.narHash;
            }
          else
            fetchGits.outPath;
        # If the problem fixed in nix, should use the following code instead
        # inherit (fetchGits) outPath;
      }
    else
      fetchGits
  else
    { }
) inputsFile
