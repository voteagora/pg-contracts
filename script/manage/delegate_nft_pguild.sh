
#!/usr/bin/env bash
set -euo pipefail

# ====== CONFIG ======
CONTRACT_ADDRESS="0xe3d4a55f780c5ad9b3009523cb6a3d900a8fa723"
KEYSTORE_PATH="$HOME/.foundry/keystores/0xA6222"
RPC_URL="https://ethereum-sepolia.rpc.subquery.network/public"


# ====== GET MY ADDRESS ======
MY_ADDRESS=$(cast wallet address --keystore "$KEYSTORE_PATH")

# ====== DELEGATE ======
echo "Delegating voting power to myself ($MY_ADDRESS)..."

cast send "$CONTRACT_ADDRESS" \
    "delegate(address)" "$MY_ADDRESS" \
    --keystore "$KEYSTORE_PATH" \
    --rpc-url "$RPC_URL"

echo "✅ Delegation transaction sent."


