{ fetchFromGitHub
, buildGoModule
, sqlite
}:

buildGoModule {
  pname = "torrent-ratio";
  version = "unstable-2023-12-25";

  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "torrent-ratio";
    rev = "ee12d583ab2cfe0cc8810e0b5b44d76f65b0e0e9";
    sha256 = "sha256-/KM3Mqbe76w0d5NaAkRRA757o8Fsdx2fZiHz0ueBouI=";
  };

  vendorHash = "sha256-4NAwh2sp1SBVniMmx6loFMN/9gbY3kfWnHV/U0TIgHg=";

  buildInputs = [ sqlite ];
}
