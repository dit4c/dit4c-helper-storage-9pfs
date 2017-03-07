#!/usr/bin/env bats

IMAGE="$BATS_TEST_DIRNAME/../dist/dit4c-helper-storage-9pfs.linux.amd64.aci"
RKT_DIR="$BATS_TMPDIR/rkt-env"
RKT_STAGE1="$BATS_TEST_DIRNAME/../build/rkt/stage1-coreos.aci"
RKT="$BATS_TEST_DIRNAME/../build/rkt/rkt --dir=$RKT_DIR"

teardown() {
  sudo $RKT gc --grace-period=0s
}

@test "curl supports HTTPS" {
  run sudo $RKT run --insecure-options=image --stage1-path=$RKT_STAGE1 \
    $IMAGE \
    --exec /usr/bin/curl -- -V
  echo $output
  [ "$status" -eq 0 ]
  [ $(expr "${output}" : ".*Protocols: .*https.*") -ne 0 ]
}

@test "9pfuse binary runs" {
  run sudo $RKT run --insecure-options=image --stage1-path=$RKT_STAGE1 \
    $IMAGE \
    --exec /usr/local/bin/9pfuse -- --help
  echo $output
  [ "$status" -eq 1 ]
  [ $(expr "${output}" : ".*usage: .*9pfuse.*") -ne 0 ]
}

@test "fusermount binary runs" {
  run sudo $RKT run --insecure-options=image --stage1-path=$RKT_STAGE1 \
    $IMAGE \
    --exec /bin/fusermount -- -V
  echo $output
  [ "$status" -eq 0 ]
}

@test "jq binary runs" {
  run sudo $RKT run --insecure-options=image --stage1-path=$RKT_STAGE1 \
    $IMAGE \
    --exec /usr/bin/jq -- -V
  echo $output
  [ "$status" -eq 0 ]
}

@test "nmap binary runs" {
  run sudo $RKT run --insecure-options=image --stage1-path=$RKT_STAGE1 \
    $IMAGE \
    --exec /usr/bin/nmap -- --help
  echo $output
  [ "$status" -eq 0 ]
}

@test "socat binary runs" {
  run sudo $RKT run --insecure-options=image --stage1-path=$RKT_STAGE1 \
    $IMAGE \
    --exec /usr/bin/socat -- -V
  echo $output
  [ "$status" -eq 0 ]
}

@test "Runs as \"root\"" {
  run sudo $RKT run --insecure-options=image --stage1-path=$RKT_STAGE1 \
    $IMAGE \
    --exec /bin/sh -- -c "id -nu"
  echo $output
  [ $(expr "${output}" : ".*root") -ne 0 ]
}
