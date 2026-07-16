{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gawk,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "chndomains";
  version = "0-unstable-2026-06-04";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "9f9fc96cac1606c966321593f0e0a9dd24c5b0b0";
    hash = "sha256-g/ZMYMVGanLp1JZId/zbf+GLTXP1wni5ptR1sRvIOso=";
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
