#!/bin/sh

set -eux
trap 'poweroff' TERM EXIT INT

# poweroff script
cat >> /etc/crontab << 'EOF'
*/1 * * * * root shutdown +5
EOF

# basics
apt-get update
apt-get install -y curl jq git ca-certificates gnupg lsb-release

sleep 600
