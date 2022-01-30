{ stdenv, fetchFromGitHub, cacert, curl, libevent, openssl, darwin }:

stdenv.mkDerivation {
  pname = "redsocks2";
  version = "unstable-2021-08-22";
  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "redsocks";
    rev = "5a3b5a6bd3b99a6e0bafa73c57faa4db2f3b61ee";
    sha256 = "11b71a3n0iljb5nbpdgbxlsa4g94vlgdrrnwgldc5rfc8wcc2ggw";
  };
  buildInputs = [ cacert curl libevent openssl darwin.DarwinTools ];
  buileFlags = [ "DISABLE_SHADOWSOCKS=true" ];
  installPhase = ''
    install -d 0644 $out/bin
    install -m 0755 redsocks2 $out/bin
  '';
}
