#!/bin/sh

set -eux
trap 'poweroff' TERM EXIT INT

# basics
apt-get update
apt-get install -y curl jq git ca-certificates gnupg lsb-release

sleep 120
