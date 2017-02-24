#!/bin/sh

set -x

SCRIPT_DIR=$(dirname $0)

calculate_latency () {
  for hostport in $@
  do
    local host=$(echo "$hostport" | awk -F: '{print $1}')
    local port=$(echo "$hostport" | awk -F: '{print $2}')
    port=${port:-4443}
    local latency=$(nmap -p $port --script $SCRIPT_DIR/ssh_latency.nse $host 2>&1 | \
      sed -n -e '/_ssh_latency/ { s/^.*_ssh_latency: \([0-9]*\).*$/\1/p }')
    if [[ "$latency" != "" ]]; then
      echo -e "$latency\t$hostport"
    fi
  done
}

calculate_latency "$@" | \
  sort -n | \
  cut -f 2
