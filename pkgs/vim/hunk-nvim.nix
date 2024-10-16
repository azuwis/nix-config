{
  vimUtils,
  fetchFromGitHub,
  nix-update-script,
}:

vimUtils.buildVimPlugin {
  pname = "hunk.nvim";
  version = "1.5.0-unstable-2024-09-19";

  src = fetchFromGitHub {
    owner = "julienvincent";
    repo = "hunk.nvim";
    rev = "eb89245a66bdfce10436d15923bf4deb43d23c96";
    sha256 = "sha256-CbvfRmgVshzEH/EUn1/PfNzT+MChtTTmxfi+gTZ7Q6Y=";
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta.homepage = "https://github.com/julienvincent/hunk.nvim";
}
