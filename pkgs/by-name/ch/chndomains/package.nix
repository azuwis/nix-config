{
  lib,
  stdenv,
  fetchFromGitHub,
  gawk,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chndomains";
  version = "0-unstable-2025-10-26";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "b524f7faa31c43359eab372c80870581508124a1";
    hash = "sha256-31uV1m2m4ExbiIwsXfIzH35mgidn0QAuTdAWA7m+EJY=";
  };

  nativeBuildInputs = [ gawk ];

  installPhase = ''
    runHook preInstall

    awk -F/ '/^server=/ {print $2}' accelerated-domains.china.conf | grep -Fv cn.debian.org > "$out"
    cat <<EOF >> "$out"
    app.arukas.io
    bnbsky.com
    dl.google.com
    download.documentfoundation.org
    duckdns.org
    flypig.info
    ipv4.tunnelbroker.net
    lan
    EOF

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=branch"
      "--version-regex=^(.*-0[1-7])$"
    ];
  };

  meta = {
    description = "Chinese-specific configuration to improve your favorite DNS server";
    homepage = "https://github.com/felixonmars/dnsmasq-china-list";
    license = lib.licenses.wtfpl;
    maintainers = with lib.maintainers; [ azuwis ];
  };
})
