#!/bin/bash

set -ex

# Import any extra environment we might need
if [[ -f /dit4c/env.sh ]]; then
  set -a
  source /dit4c/env.sh
  set +a
fi

if [[ "$DIT4C_INSTANCE_ID" == "" ]]; then
  echo "Must specify DIT4C_INSTANCE_ID to provide to routing server"
  exit 1
fi

if [[ ! -f "$DIT4C_INSTANCE_PRIVATE_KEY_PKCS1" ]]; then
  echo "Unable to find DIT4C_INSTANCE_PRIVATE_KEY_PKCS1: $DIT4C_INSTANCE_PRIVATE_KEY_PKCS1"
  exit 1
fi

if [[ "$DIT4C_INSTANCE_URI_UPDATE_URL" == "" ]]; then
  echo "Must specify DIT4C_INSTANCE_URI_UPDATE_URL"
  exit 1
fi

PORTAL_DOMAIN=$(echo $DIT4C_INSTANCE_URI_UPDATE_URL | awk -F/ '{print $3}')

umask 0077
while true
do
  #SSH_SERVER=$(dig +short TXT $PORTAL_DOMAIN | grep -Eo "dit4c-fileserver-9pfs=[^\"]*" | cut -d= -f2 | xargs /opt/bin/sort_by_latency.sh | head -1)
  SSH_SERVER="192.168.100.1:2200"
  SSH_HOST=$(echo $SSH_SERVER | cut -d: -f1)
  SSH_PORT=$(echo $SSH_SERVER | cut -d: -f2)

  if [[ "$SSH_SERVER" == "" ]]; then
    echo "Unable to resolve file server"
    sleep 60
    continue
  fi

  TMP_KEY=$(mktemp)
  cat $DIT4C_INSTANCE_PRIVATE_KEY_PKCS1 > $TMP_KEY

  ssh -i $TMP_KEY \
    -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" \
    -p $SSH_PORT \
    register@$SSH_HOST $DIT4C_INSTANCE_ID

  socat TCP-LISTEN:564,bind=127.0.0.1,fork,reuseaddr SYSTEM:"ssh -T -i $TMP_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ServerAliveInterval=30 -p $SSH_PORT connect@$SSH_HOST" &
  SOCAT_PID=$!

  # Setup /dev/fuse
  test -c /dev/fuse || mknod /dev/fuse c 10 229
	chmod 666 /dev/fuse

  # Mount storage
  mkdir -p /dev/shm/storage-9pfs
  test -d /mnt/private || ln -s /dev/shm/storage-9pfs /mnt/private
  /usr/local/bin/9pfuse -D 127.0.0.1:564 /dev/shm/storage-9pfs
  FUSE_PID=$?

  wait $SOCAT_PID
done
