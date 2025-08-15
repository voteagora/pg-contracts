
#!/usr/bin/env bash
set -euo pipefail

# ====== CONFIG ======
CONTRACT_ADDRESS="0x2a6a9a2a3f6f3420e26410ca5868ed1cb241a7ba"
KEYSTORE_PATH="$HOME/.foundry/keystores/0xA6222"
RPC_URL="https://ethereum-sepolia.rpc.subquery.network/public"


# ====== GET MY ADDRESS ======
MY_ADDRESS=$(cast wallet address --keystore "$KEYSTORE_PATH")



cast send "$CONTRACT_ADDRESS" \
    "setManager(address)" "0xb11dc2953e36b11d1d650a9ca4dc8741ae5519fc" \
    --keystore "$KEYSTORE_PATH" \
    --rpc-url "$RPC_URL"

