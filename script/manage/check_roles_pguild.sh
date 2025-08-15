#!/usr/bin/env bash
set -euo pipefail

# ====== CONFIG ======
CONTRACT_ADDRESS="0xe3d4a55f780c5ad9b3009523cb6a3d900a8fa723"
KEYSTORE_PATH="$HOME/.foundry/keystores/0xA6222"
RPC_URL="https://ethereum-sepolia.rpc.subquery.network/public"

# ====== CHECK ARGS ======
if [ $# -ne 1 ]; then
    echo "Usage: $0 <address_to_check>"
    exit 1
fi
ADDRESS_TO_CHECK="$1"

# ====== HELPER FUNCTION ======
check_role() {
    local ROLE_NAME=$1
    local ROLE_HASH
    ROLE_HASH=$(cast keccak "$ROLE_NAME")

    echo "== $ROLE_NAME ($ROLE_HASH) =="

    HAS_ROLE=$(cast call "$CONTRACT_ADDRESS" \
        "hasRole(bytes32,address)(bool)" "$ROLE_HASH" "$ADDRESS_TO_CHECK" \
        --rpc-url "$RPC_URL")

    if [ "$HAS_ROLE" == "true" ]; then
        echo "✅ $ADDRESS_TO_CHECK HAS $ROLE_NAME"
        return 0
    else
        echo "❌ $ADDRESS_TO_CHECK does NOT have $ROLE_NAME"
        return 1
    fi
}

# ====== EXECUTION ======
echo "Checking roles for $ADDRESS_TO_CHECK..."

HAS_MINTER=false
HAS_BURNER=false

if check_role "MINTER_ROLE"; then HAS_MINTER=true; fi
if check_role "BURNER_ROLE"; then HAS_BURNER=true; fi

echo
if [ "$HAS_MINTER" = true ] && [ "$HAS_BURNER" = true ]; then
    echo "✅ $ADDRESS_TO_CHECK has BOTH MINTER_ROLE and BURNER_ROLE"
else
    echo "❌ $ADDRESS_TO_CHECK does NOT have both roles"
fi

echo "Done."
