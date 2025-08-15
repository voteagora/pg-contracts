
#!/usr/bin/env bash
set -euo pipefail

# ====== CONFIG ======
KEYSTORE_PATH="$HOME/.foundry/keystores/0xC950b"
RPC_URL="https://ethereum-sepolia.rpc.subquery.network/public"


# Replace with your list of addresses
addresses=(
   0xc2658A2d5ADf4a4F08f5c9b83D39816951465538
   0xcC0B26236AFa80673b0859312a7eC16d2b72C1ea 
   0x57dBb5F3b3806746097423BAFD825F3B12B2523b 
   0x2A169e4fBda18AA291608e7Aa8795271d18099F5
   0x4F9CCD8C2d017EaDD0CdAaC6692c9BcD96c92e53
   0x9E65064B22dE40fD1232C893Df71022Ce92aC30A
   0x0a17024004d0d0b5b5110d5B9E4Fd179Fc99Dc24
   0x22f2F5A4eAD6f42761Bf8A7cD340de684A51fc07
)

# Amount in ETH
amount="0.01"

# Loop and send
for addr in "${addresses[@]}"; do
  cast send \
    --rpc-url "$RPC_URL" \
    --keystore "$KEYSTORE_PATH" \
    --value "$(cast to-wei $amount ether)" \
    "$addr"
done
