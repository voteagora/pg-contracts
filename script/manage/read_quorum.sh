
#!/usr/bin/env bash
set -euo pipefail

# ====== CONFIG ======
CONTRACT_ADDRESS="0x2a6a9a2a3f6f3420e26410ca5868ed1cb241a7ba"
RPC_URL="https://ethereum-sepolia.rpc.subquery.network/public"


cast call "$CONTRACT_ADDRESS" \
    "quorum(uint256)" 8630244923579021985610047533050214574161619092542808041701733522763008152147 \
    --rpc-url "$RPC_URL"

