#!/bin/sh

set -ex

# Configure DNS
rm /etc/resolv.conf
echo nameserver 8.8.8.8 > /etc/resolv.conf

# Install packages
apk update
apk add curl openssh nmap bind-tools nmap nmap-nselibs nmap-scripts socat
rm -rf /var/cache/apk/*

# Cleanup DNS config
rm -f /etc/resolv.conf
