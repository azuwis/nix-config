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
curl -Ls https://github.com/misakaio/chnroutes2/raw/master/chnroutes.txt | grep -v '^#'
) | mapcidr -silent -aggregate | sort -V > local-cidr
