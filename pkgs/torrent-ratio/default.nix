{ lib, fetchFromGitHub, buildGoModule, sqlite }:

buildGoModule rec {
  pname = "torrent-ratio";
  version = "unstable-2023-06-14";

  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "torrent-ratio";
    rev = "63305a40d24a7a85e0d36b2610ae7777f892829f";
    sha256 = "0izl58xzm07zk7jsh2z8z622hcyi0zx0v1skwdaa75fyxsw8bdpv";
  };

  vendorSha256 = "sha256-HH0VHleShuv91QkV1CC8thgBWe5RgoUKhXa706Ked04=";

  buildInputs = [ sqlite ];
}
