{
  lib,
  stdenv,
  fetchFromGitHub,
  gawk,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chndomains";
  version = "0-unstable-2024-09-13";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "de3ee295b7a542414035e5c908c952e290dde655";
    hash = "sha256-ogjkT3b4hz3yN35e4b88T1A/i7hZQ0rP0u1sR1g4QIE=";
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

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Chinese-specific configuration to improve your favorite DNS server";
    homepage = "https://github.com/felixonmars/dnsmasq-china-list";
    license = lib.licenses.wtfpl;
    maintainers = with lib.maintainers; [ azuwis ];
  };
})
