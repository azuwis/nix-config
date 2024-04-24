{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
}:

buildPythonPackage rec {
  pname = "pySonyBraviaPSK";
  version = "0.2.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-FV/VVAvj58wW8bo9ZGRXyGihZdeMZ4+LdjNns7VUB5Q=";
  };

  propagatedBuildInputs = [ requests ];

  doCheck = false;

  meta = with lib; {
    description = "Sony Bravia PSK library for Home Assistant";
    homepage = "https://github.com/gerard33/sony_bravia_psk";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ azuwis ];
  };
}
