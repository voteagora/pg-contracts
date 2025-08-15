
#!/usr/bin/env bash
set -euo pipefail

# ====== CONFIG ======
CONTRACT_ADDRESS="0xe3d4a55f780c5ad9b3009523cb6a3d900a8fa723"
KEYSTORE_PATH="$HOME/.foundry/keystores/0xC0d87"
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
BURNER_ROLE=$(cast keccak "BURNER_ROLE")
echo "BURNER_ROLE hash: $BURNER_ROLE"

# ====== CHECK IF I HAVE MINTER_ROLE ======
HAS_ROLE=$(cast call "$CONTRACT_ADDRESS" \
    "hasRole(bytes32,address)(bool)" "$BURNER_ROLE" "$MY_ADDRESS" \
    --rpc-url "$RPC_URL")

if [ "$HAS_ROLE" != "true" ]; then
    echo "❌ You do NOT have the right role. Cannot burn."
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
    "burn(uint256[])" "$ARRAY_ARG" \
    --keystore "$KEYSTORE_PATH" \
    --rpc-url "$RPC_URL"

echo "🎉 Burn successful."
