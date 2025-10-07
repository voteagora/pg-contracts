#!/usr/bin/env bash
set -euo pipefail

KEYSTORE_PATH="$HOME/.foundry/keystores/0xA6222"

forge script script/deploy/RelinquishTimelock.s.sol:RelinquishTimelock \
  --rpc-url http://127.0.0.1:8545 \
  --broadcast \
  --keystore "$KEYSTORE_PATH"
