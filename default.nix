let
  flake-compat =
    let
      lock = builtins.fromJSON (builtins.readFile ./flake.lock);
      inherit (lock.nodes.${lock.nodes.${lock.root}.inputs.flake-compat}.locked)
        owner
        repo
        rev
        narHash
        ;
    in
    builtins.fetchTarball {
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      sha256 = narHash;
    };
  flake = import flake-compat {
    src = ./.;
  };
  self = flake.defaultNix;
in
self
