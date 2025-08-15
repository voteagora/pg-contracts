
#!/usr/bin/env bash
set -euo pipefail

# ====== CONFIG ======
CONTRACT_ADDRESS="0xe3d4a55f780c5ad9b3009523cb6a3d900a8fa723"
KEYSTORE_PATH="$HOME/.foundry/keystores/0xA6222"
RPC_URL="https://ethereum-sepolia.rpc.subquery.network/public"


# ====== CHECK ARGS ======
if [ $# -lt 1 ]; then
    echo "Usage: $0 <recipient_address_1> [<recipient_address_2> ...]"
    exit 1
fi


RECIPIENTS=("$@")  # array of recipient addresses

# ====== GET MY ADDRESS ======
MY_ADDRESS=$(cast wallet address --keystore "$KEYSTORE_PATH")

# ====== MINTER ROLE HASH ======
MINTER_ROLE=$(cast keccak "MINTER_ROLE")
echo "MINTER_ROLE hash: $MINTER_ROLE"

# ====== CHECK IF I HAVE MINTER_ROLE ======
HAS_MINTER=$(cast call "$CONTRACT_ADDRESS" \
    "hasRole(bytes32,address)(bool)" "$MINTER_ROLE" "$MY_ADDRESS" \
    --rpc-url "$RPC_URL")

if [ "$HAS_MINTER" != "true" ]; then
    echo "❌ You do NOT have MINTER_ROLE. Cannot mint."
    exit 1
fi

# ====== FORMAT ARRAY ARG ======
# Join array elements with commas
ARRAY_ARG="["
for i in "${!RECIPIENTS[@]}"; do
    ARRAY_ARG+="${RECIPIENTS[$i]}"
    if [ "$i" -lt $((${#RECIPIENTS[@]} - 1)) ]; then
        ARRAY_ARG+=","
    fi
done
ARRAY_ARG+="]"


# ====== MINT ======
echo "✅ You have MINTER_ROLE. Minting to: ${RECIPIENTS[*]}"
cast send "$CONTRACT_ADDRESS" \
    "mint(address[])" "$ARRAY_ARG" \
    --keystore "$KEYSTORE_PATH" \
    --rpc-url "$RPC_URL"

echo "🎉 Mint successful."
