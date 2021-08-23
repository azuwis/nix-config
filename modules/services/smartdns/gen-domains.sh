#!/usr/bin/env sh
curl -Ls https://github.com/felixonmars/dnsmasq-china-list/raw/master/accelerated-domains.china.conf | sed -e 's!/114.114.114.114$!/127.0.0.53!' | grep -Fv cn.debian.org | awk -F/ '{print $2}' > domains

cat <<EOF >> domains
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
