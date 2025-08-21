{
  vimUtils,
  fetchFromGitHub,
  nix-update-script,
}:

vimUtils.buildVimPlugin rec {
  pname = "hunk.nvim";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "julienvincent";
    repo = "hunk.nvim";
    rev = "v${version}";
    sha256 = "sha256-CKQe3kv7bX21DDqSV2S093Afs8jiAzZiLHByjWFSWDQ=";
  };

  passthru.enable = false;
  passthru.updateScript = nix-update-script { };

  meta.homepage = "https://github.com/julienvincent/hunk.nvim";
}
