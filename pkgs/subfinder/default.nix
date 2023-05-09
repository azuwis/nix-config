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
  version = "unstable-2023-04-19";

  src = fetchFromGitHub {
    owner = "ausaki";
    repo = "subfinder";
    rev = "885962139e5068154946bf13283ca52c341f01ff";
    sha256 = "1srvvr3zw4kc5a3s1jagb36pxxx60zlaazs35qmzd1wsppmxhamb";
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
