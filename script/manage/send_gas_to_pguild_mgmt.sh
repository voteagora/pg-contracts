
#!/usr/bin/env bash
set -euo pipefail

# ====== CONFIG ======
KEYSTORE_PATH="$HOME/.foundry/keystores/0xC950b"
RPC_URL="https://ethereum-sepolia.rpc.subquery.network/public"


# Replace with your list of addresses
addresses=(
   0xC0d8767b71A30709A04639C46cd6f4Cb352aCB4c
   0x0169E137A379e9B3B5B94D42E5e52a1C7291574f
   0xB11dc2953e36b11D1D650A9cA4Dc8741Ae5519Fc
)

# Amount in ETH
amount="0.005"

# Loop and send
for addr in "${addresses[@]}"; do
  cast send \
    --rpc-url "$RPC_URL" \
    --keystore "$KEYSTORE_PATH" \
    --value "$(cast to-wei $amount ether)" \
    "$addr"
done
