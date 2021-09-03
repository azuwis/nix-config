{ stdenv, fetchFromGitHub, cacert, curl, libevent, openssl }:

stdenv.mkDerivation {
  pname = "redsocks2";
  version = "2021-08-22";
  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "redsocks";
    rev = "a73d1ed28ade6173746bca27c4c9c770c026b103";
    sha256 = "0g422q13gaf2vhfwjv77h94m72c08lxp14q3rznihbhhnw8sbv76";
  };
  buildInputs = [ cacert curl libevent openssl ];
  buileFlags = [ "DISABLE_SHADOWSOCKS=true" ];
  installPhase = ''
    install -d 0644 $out/bin
    install -m 0755 redsocks2 $out/bin
  '';
}
