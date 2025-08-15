
#!/usr/bin/env bash
set -euo pipefail

# ====== CONFIG ======
CONTRACT_ADDRESS="0xe3d4a55f780c5ad9b3009523cb6a3d900a8fa723"
KEYSTORE_PATH="$HOME/.foundry/keystores/0xA6222"
RPC_URL="https://ethereum-sepolia.rpc.subquery.network/public"


# Pass token ID as the first argument to the script
if [ $# -ne 1 ]; then
  echo "Usage: $0 <tokenId>"
  exit 1
fi

TOKEN_ID="$1"

# Call ownerOf
cast call \
  --rpc-url "$RPC_URL" \
  "$CONTRACT_ADDRESS" \
  "ownerOf(uint256)" "$TOKEN_ID"

