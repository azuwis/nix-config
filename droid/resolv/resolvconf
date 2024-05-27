#!/usr/bin/env bash

# adb shell pm grant com.termux.nix android.permission.DUMP

re='Active default network: ([0-9]+)'
got_active=false
got_network=false
while read -r line
do
  if [ "$got_active" = "false" ] && [[ ${line} =~ $re ]]
  then
    re="NetworkAgentInfo\{network\{${BASH_REMATCH[1]}\}.* LinkAddresses: \[.*[ ,]([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/[^ ]* \] DnsAddresses: \[ [^ ]*/([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)[ ,]"
    got_active=true
  elif [ "$got_network" = "false" ] && [ "$got_active" = "true" ] && [[ ${line} =~ $re ]] 
  then
    ip="${BASH_REMATCH[1]}"
    nameserver="${BASH_REMATCH[2]}"
    echo "ip		$ip" 1>&2
    echo "nameserver	$nameserver" 1>&2
    echo "nameserver $nameserver" > /etc/resolv.conf
    got_network=true
  fi
done < <(/system/bin/dumpsys connectivity)
