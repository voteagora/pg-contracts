
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
cast calldata "mint(address[])" "$ARRAY_ARG"
