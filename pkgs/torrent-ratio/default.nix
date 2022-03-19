{ lib, fetchFromGitHub, buildGoModule, sqlite }:

buildGoModule rec {
  pname = "torrent-ratio";
  version = "unstable-2022-03-19";

  src = fetchFromGitHub {
    owner = "azuwis";
    repo = pname;
    rev = "436d0f6b7825183cc4c3b1ce8a1a842668993233";
    sha256 = "sha256-yJ3i5PNnSUxcwRkT23uL8mcEtDieskfaf3mt1vJqbZk=";
  };

  vendorSha256 = "sha256-HH0VHleShuv91QkV1CC8thgBWe5RgoUKhXa706Ked04=";

  buildInputs = [ sqlite ];
}
