#!/usr/bin/env nix-shell
#!nix-shell -i bash -p mapcidr
(
cat <<EOF
0.0.0.0/8
10.0.0.0/8
100.64.0.0/10
172.16.0.0/12
192.0.0.0/24
192.0.2.0/24
192.88.99.0/24
192.168.0.0/16
198.18.0.0/15
198.51.100.0/24
203.0.113.0/24
EOF
curl -s 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }'
) | mapcidr -silent -aggregate | sort -V > local-cidr
