#!/bin/sh

. /lib/functions.sh

wanlimit_rules=""
handle_redirect() {
  local src src_dport wanlimit proto
  config_get src "$1" src
  config_get src_dport "$1" src_dport
  config_get wanlimit "$1" wanlimit
  config_get proto "$1" proto "tcp udp"
  [ "$src" = "wan" ] && [ -n "$src_dport" ] && [ -n "$wanlimit" ] || return
  local nft_proto
  nft_proto="meta l4proto { ${proto// /, } }"
  wanlimit_rules="$wanlimit_rules
		iifname \"wan\" $nft_proto th dport $src_dport ct state new add @wanlimit_meter { ip saddr . th dport limit rate over $wanlimit } add @wanlimit_ban { ip saddr } counter drop"
}

config_load firewall
config_foreach handle_redirect redirect

[ -z "$wanlimit_rules" ] && exit 0

nft -f - <<EOF
table inet fw4 {
	set wanlimit_ban {
		type ipv4_addr
		flags timeout
		timeout 24h
	}

	set wanlimit_meter {
		type ipv4_addr . inet_service
		flags dynamic, timeout
		timeout 2m
	}

	chain wanlimit {
		type filter hook prerouting priority -110; policy accept;
		iifname "wan" ip saddr @wanlimit_ban counter drop
$wanlimit_rules
	}
}
EOF
