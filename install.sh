#!/bin/bash

set -ex

# Configure DNS
rm /etc/resolv.conf
echo nameserver 8.8.8.8 > /etc/resolv.conf

# Install packages
apt-get update
apt-get install -y curl fuse jq nmap openssh-client socat
apt-get clean

# Cleanup DNS config
rm -f /etc/resolv.conf
