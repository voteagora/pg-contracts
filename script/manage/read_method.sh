
#!/usr/bin/env bash
set -euo pipefail

# ====== CONFIG ======
CONTRACT_ADDRESS="0xe3d4a55f780c5ad9b3009523cb6a3d900a8fa723"
KEYSTORE_PATH="$HOME/.foundry/keystores/0xA6221"
RPC_URL="https://ethereum-sepolia.rpc.subquery.network/public"


cast call "$CONTRACT_ADDRESS" \
    "getPastTotalSupply(uint256)" 8985083 \
    --rpc-url "$RPC_URL"

