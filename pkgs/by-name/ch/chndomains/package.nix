{
  lib,
  stdenv,
  fetchFromGitHub,
  gawk,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chndomains";
  version = "0-unstable-2025-02-26";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "6601f38990c06909d69364685a8ef4f3544e1e69";
    hash = "sha256-veQRHpT/TU7bQz7t7hoZvVtqR6eaXn+O7C8xu2oNFes=";
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
