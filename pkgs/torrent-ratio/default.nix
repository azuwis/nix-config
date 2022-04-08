{ lib, fetchFromGitHub, buildGoModule, sqlite }:

buildGoModule rec {
  pname = "torrent-ratio";
  version = "unstable-2022-03-19";

  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "torrent-ratio";
    rev = "436d0f6b7825183cc4c3b1ce8a1a842668993233";
    sha256 = "16bddbrddbbrgzd4gcly72s08rzjidxxn4qrq5f4qjb7ygjf57f8";
  };

  vendorSha256 = "sha256-HH0VHleShuv91QkV1CC8thgBWe5RgoUKhXa706Ked04=";

  buildInputs = [ sqlite ];
}
