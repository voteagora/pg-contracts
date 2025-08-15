
#!/usr/bin/env bash
set -euo pipefail

# ====== CONFIG ======
CONTRACT_ADDRESS="0xe3d4a55f780c5ad9b3009523cb6a3d900a8fa723"
KEYSTORE_PATH="$HOME/.foundry/keystores/0xA6222"
RPC_URL="https://ethereum-sepolia.rpc.subquery.network/public"

# ====== CHECK ARGS ======
if [ $# -ne 1 ]; then
    echo "Usage: $0 <recipient_address>"
    exit 1
fi
RECIPIENT="$1"

# ====== GET MY ADDRESS FROM KEYSTORE ======
MY_ADDRESS=$(cast wallet address --keystore "$KEYSTORE_PATH")

# ====== HELPER FUNCTION ======
grant_role_if_admin() {
    local ROLE_NAME=$1
    local ROLE_HASH=$(cast keccak "$ROLE_NAME")

    echo "== $ROLE_NAME ($ROLE_HASH) =="

    # Find admin role for this role
    ADMIN_ROLE=$(cast call "$CONTRACT_ADDRESS" \
        "getRoleAdmin(bytes32)(bytes32)" "$ROLE_HASH" \
        --rpc-url "$RPC_URL")

    echo "Admin role for $ROLE_NAME is $ADMIN_ROLE"

    # Check if MY_ADDRESS has that admin role
    HAS_ADMIN=$(cast call "$CONTRACT_ADDRESS" \
        "hasRole(bytes32,address)(bool)" "$ADMIN_ROLE" "$MY_ADDRESS" \
        --rpc-url "$RPC_URL")

    if [ "$HAS_ADMIN" == "true" ]; then
        echo "✅ You have admin rights for $ROLE_NAME. Granting to $RECIPIENT..."
        cast send "$CONTRACT_ADDRESS" \
            "grantRole(bytes32,address)" "$ROLE_HASH" "$RECIPIENT" \
            --keystore "$KEYSTORE_PATH" \
            --rpc-url "$RPC_URL"
    else
        echo "❌ You do NOT have admin rights for $ROLE_NAME. Skipping..."
    fi
}

# ====== EXECUTION ======
grant_role_if_admin "MINTER_ROLE"
grant_role_if_admin "BURNER_ROLE"

echo "Done."
