{
  lib,
  stdenv,
  fetchFromGitHub,
  gawk,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chndomains";
  version = "0-unstable-2025-05-18";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "0cd2fb6c2e3ed1711e3eb6dd1cb1318db3e47808";
    hash = "sha256-JAXgXGA2xtBHTpGw0D0DnPSdcbhNLLu0z6UGjar8AVQ=";
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
