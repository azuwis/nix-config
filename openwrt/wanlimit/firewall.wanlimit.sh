#!/bin/sh
# shellcheck disable=SC1091,SC3043,SC3060

. /lib/functions.sh
. /lib/functions/network.sh

METER_TIMEOUT=$(uci -q get wanlimit.@wanlimit[0].meter_timeout || echo "1h")
BAN_TIMEOUTS=$(uci -q get wanlimit.@wanlimit[0].ban_timeouts || echo "1h 1d 7d")
DEFAULT_LIMIT_RATE=$(uci -q get wanlimit.@wanlimit[0].limit_rate)

wanlimit_rules=""
handle_firewall_redirect() {
  local src src_dport proto limit_rate nft_proto
  config_get src "$1" src
  config_get src_dport "$1" src_dport
  config_get proto "$1" proto "tcp udp"
  [ "$src" = "wan" ] && [ -n "$src_dport" ] || return
  limit_rate=$(uci -q get "wanlimit.@wanlimit[0].limit_rate_${src_dport}" || echo "$DEFAULT_LIMIT_RATE")
  [ -n "$limit_rate" ] || return
  nft_proto="meta l4proto { ${proto// /, } }"
  wanlimit_rules="$wanlimit_rules
		$iif_match $nft_proto th dport $src_dport ct state new add @wanlimit_meter { ip saddr limit rate over $limit_rate } goto wanlimit_escalate"
}
config_load firewall

# Resolve wan zone device names
wan_devices=""
_add_wan_device() {
  local dev
  network_get_device dev "$1" || return
  [ -n "$dev" ] || return
  case " $wan_devices " in
  *" $dev "*) return ;;
  esac
  wan_devices="$wan_devices $dev"
}
_handle_wan_zone() {
  local name
  config_get name "$1" name
  [ "$name" = "wan" ] || return
  config_list_foreach "$1" network _add_wan_device
}
config_foreach _handle_wan_zone zone

nft_iifname=""
for dev in $wan_devices; do
  nft_iifname="${nft_iifname:+$nft_iifname, }\"$dev\""
done
[ -z "$nft_iifname" ] && exit 0
iif_match="iifname { $nft_iifname }"

config_foreach handle_firewall_redirect redirect

[ -z "$wanlimit_rules" ] && exit 0

level_sets=""

# shellcheck disable=SC2086
set -- $BAN_TIMEOUTS
if [ $# -eq 1 ]; then
  escalate_rules="		update @wanlimit_ban { ip saddr timeout $1 } log prefix \"wanlimit ban $1 \" counter drop"
else
  escalate_rules="		add @wanlimit_level0 { ip saddr } update @wanlimit_ban { ip saddr timeout $1 } log prefix \"wanlimit ban $1 \" counter drop"
fi
shift
level=0
while [ $# -gt 0 ]; do
  level_sets="$level_sets
	set wanlimit_level${level} {
		type ipv4_addr
		flags dynamic, timeout
		timeout $1
	}
"
  if [ $# -eq 1 ]; then
    escalate_rules="		ip saddr @wanlimit_level${level} update @wanlimit_ban { ip saddr timeout $1 } log prefix \"wanlimit ban $1 \" counter drop
$escalate_rules"
  else
    next_level=$((level + 1))
    escalate_rules="		ip saddr @wanlimit_level${level} add @wanlimit_level${next_level} { ip saddr } update @wanlimit_ban { ip saddr timeout $1 } log prefix \"wanlimit ban $1 \" counter drop
$escalate_rules"
  fi
  level=$((level + 1))
  shift
done

nft -f - <<EOF
table inet fw4 {
	set wanlimit_ban {
		type ipv4_addr
		flags dynamic, timeout
	}
$level_sets
	set wanlimit_meter {
		type ipv4_addr
		flags dynamic, timeout
		timeout $METER_TIMEOUT
	}

	chain wanlimit_escalate {
$escalate_rules
	}

	chain wanlimit {
		type filter hook prerouting priority -110; policy accept;
		$iif_match ip saddr @wanlimit_ban counter drop
$wanlimit_rules
	}
}
EOF
