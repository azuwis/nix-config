{ lib
, buildPythonPackage
, fetchFromGitHub
, requests
, lxml
, beautifulsoup4
, gevent
, rarfile
, setuptools
, six
}:

buildPythonPackage rec {
  pname = "subfinder";
  version = "unstable-2022-12-18";

  src = fetchFromGitHub {
    owner = "ausaki";
    repo = "subfinder";
    rev = "ebe6e67d9f20083ee10eb945d9a43431cff06b8a";
    sha256 = "sha256-vgmGA5SDDhC9QkEND08KFaVq2oLZX51Uwhs0fCinbwY=";
  };

  propagatedBuildInputs = [ requests lxml beautifulsoup4 gevent rarfile setuptools six ];

  doCheck = false;

  postPatch = ''
    substituteInPlace setup.py --replace "bs4" "beautifulsoup4"
  '';

  meta = with lib; {
    description = "Subtitle finder";
    homepage = "https://github.com/ausaki/subfinder";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ azuwis ];
  };
}
