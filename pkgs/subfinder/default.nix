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
  version = "unstable-2023-01-26";

  src = fetchFromGitHub {
    owner = "ausaki";
    repo = "subfinder";
    rev = "165cf98afa23b39f84bb121eb7e9c8e855df0745";
    sha256 = "11ihlmd99p40frk4x3z2nclp35xn5bk59x81prhn4sh02smyy57z";
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
