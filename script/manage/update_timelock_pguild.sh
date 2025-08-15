
#!/usr/bin/env bash
set -euo pipefail

# ====== CONFIG ======
CONTRACT_ADDRESS="0xF5B87BD1206d7658C344Fe1CB56D9498B4286A67"
KEYSTORE_PATH="$HOME/.foundry/keystores/0xA6222"
RPC_URL="https://ethereum-sepolia.rpc.subquery.network/public"


# ====== GET MY ADDRESS ======
MY_ADDRESS=$(cast wallet address --keystore "$KEYSTORE_PATH")


cast calldata "updateDelay(uint256)" 25

echo "✅ transaction sent."


