{
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "torrent-ratio";
  version = "0.9";

  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "torrent-ratio";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-v2qP3zklL/qs9pD63VkTrVhLNm34RQzDc1NvSXX8ZhU=";
  };

  vendorHash = "sha256-RH38kK6r357K9YgjgyHxd9iSlBK7i1MgwETN9NNeVU4=";

  passthru.updateScript = nix-update-script { };
})
