#!/usr/bin/env sh
curl -Ls https://github.com/felixonmars/dnsmasq-china-list/raw/master/accelerated-domains.china.conf | awk -F/ '/^server=/ {print $2}' | grep -Fv cn.debian.org > local-domains

cat <<EOF >> local-domains
app.arukas.io
bnbsky.com
dl.google.com
download.documentfoundation.org
duckdns.org
flypig.info
ipv4.tunnelbroker.net
lan
netease.com
wswebcdn.com
EOF
