#!/usr/bin/env bash
set -euo pipefail

# Simple helper to (re)create a local Nami chain genesis with:
# - 1 validator wallet
# - 1 community wallet
# - 70% / 30% supply split by default
#
# It writes the resulting genesis and validator keys into the repo's ./config/
# so that docker-compose picks them up.
#
# Requirements:
#   - Run from the repo root
#   - Binary built at ./build/namid  (make build)
#
# You can override defaults via env vars, e.g.:
#   CHAIN_ID=nami_101012026-1 VALIDATOR_AMOUNT=700000000000000nami COMMUNITY_AMOUNT=300000000000000nami ./scripts/init-local-nami-chain.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Load .env file if it exists
if [ -f "$ROOT_DIR/.env" ]; then
  echo ">>> Loading configuration from .env file ..."
  # shellcheck source=/dev/null
  set -a
  source "$ROOT_DIR/.env"
  set +a
fi

BINARY="${BINARY:-./build/namid}"
HOME_DIR="${HOME_DIR:-.local-namid}"

CHAIN_ID="${CHAIN_ID:-nami_101012026-1}"
MONIKER="${MONIKER:-namitestnet}"

VALIDATOR_KEY_NAME="${VALIDATOR_KEY_NAME:-validator-wallet}"
COMMUNITY_KEY_NAME="${COMMUNITY_KEY_NAME:-community-wallet}"

# Default: 1_000_000_000 * 10^6 (1e15) supply with 70/30 split
VALIDATOR_AMOUNT="${VALIDATOR_AMOUNT:-700000000000000tunami}"
COMMUNITY_AMOUNT="${COMMUNITY_AMOUNT:-300000000000000tunami}"

echo ">>> Using binary:        $BINARY"
echo ">>> Working home:        $HOME_DIR"
echo ">>> Chain ID:            $CHAIN_ID"
echo ">>> Moniker:             $MONIKER"
echo ">>> Validator key name:  $VALIDATOR_KEY_NAME"
echo ">>> Community key name:  $COMMUNITY_KEY_NAME"
echo ">>> Validator amount:    $VALIDATOR_AMOUNT"
echo ">>> Community amount:    $COMMUNITY_AMOUNT"
echo

if [ ! -x "$BINARY" ]; then
  echo "Binary $BINARY not found or not executable. Build it first with: make build"
  exit 1
fi

echo ">>> Clean old local home: $HOME_DIR"
rm -rf "$HOME_DIR"

echo ">>> Clean old docker data home: $ROOT_DIR/data"
rm -rf "$ROOT_DIR/data"

echo ">>> namid init ..."
# Auto-detect denom: use tunami for testnet chain IDs, unami for mainnet
if [[ "$CHAIN_ID" == *"testnet"* ]] || [[ "$CHAIN_ID" == *"test"* ]] || [[ "$CHAIN_ID" == *"101012026"* ]]; then
  DEFAULT_BOND_DENOM="tunami"
else
  DEFAULT_BOND_DENOM="unami"
fi
"$BINARY" init "$MONIKER" --chain-id "$CHAIN_ID" --default-denom "$DEFAULT_BOND_DENOM" --home "$HOME_DIR"
echo "    Created new priv_validator_key.json and node_key.json with denom: $DEFAULT_BOND_DENOM"

echo ">>> Create keys (validator & community) ..."
# Use existing mnemonics if provided in .env, otherwise create new keys
if [ -n "${VALIDATOR_MNEMONIC:-}" ]; then
  echo "    Recovering validator key from mnemonic ..."
  echo "$VALIDATOR_MNEMONIC" | "$BINARY" keys add "$VALIDATOR_KEY_NAME" --recover --keyring-backend test --home "$HOME_DIR" --algo "eth_secp256k1"
else
  echo "    Creating new validator key ..."
  "$BINARY" keys add "$VALIDATOR_KEY_NAME" --keyring-backend test --home "$HOME_DIR" --algo "eth_secp256k1"
fi

if [ -n "${COMMUNITY_MNEMONIC:-}" ]; then
  echo "    Recovering community key from mnemonic ..."
  echo "$COMMUNITY_MNEMONIC" | "$BINARY" keys add "$COMMUNITY_KEY_NAME" --recover --keyring-backend test --home "$HOME_DIR" --algo "eth_secp256k1"
else
  echo "    Creating new community key ..."
  "$BINARY" keys add "$COMMUNITY_KEY_NAME" --keyring-backend test --home "$HOME_DIR" --algo "eth_secp256k1"
fi

VAL_ADDR="$("$BINARY" keys show "$VALIDATOR_KEY_NAME" -a --keyring-backend test --home "$HOME_DIR")"
COMM_ADDR="$("$BINARY" keys show "$COMMUNITY_KEY_NAME" -a --keyring-backend test --home "$HOME_DIR")"

echo "    Validator address : $VAL_ADDR"
echo "    Community address : $COMM_ADDR"

echo ">>> Add genesis accounts (allocate supply) ..."
"$BINARY" add-genesis-account "$VAL_ADDR"   "$VALIDATOR_AMOUNT"   --home "$HOME_DIR"
"$BINARY" add-genesis-account "$COMM_ADDR"  "$COMMUNITY_AMOUNT"   --home "$HOME_DIR"

echo ">>> gentx (make validator from validator-wallet) ..."
"$BINARY" gentx "$VALIDATOR_KEY_NAME" "$VALIDATOR_AMOUNT" \
  --chain-id "$CHAIN_ID" \
  --moniker "$MONIKER" \
  --commission-rate="0.10" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --keyring-backend test \
  --home "$HOME_DIR"

echo ">>> collect-gentxs & validate-genesis ..."
"$BINARY" collect-gentxs   --home "$HOME_DIR"

# Fix denom in ERC20 and Inflation modules (they use hardcoded BaseDenom in code)
GENESIS_FILE="$HOME_DIR/config/genesis.json"
if command -v jq &> /dev/null; then
  echo "    Fixing denom in ERC20 and Inflation modules to: $DEFAULT_BOND_DENOM"
  jq --arg denom "$DEFAULT_BOND_DENOM" \
    '.app_state.erc20.token_pairs[0].denom = $denom | 
     .app_state.inflation.params.mint_denom = $denom' \
    "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
else
  echo "    WARNING: jq not found. Please manually fix denom in ERC20 and Inflation modules in genesis.json"
fi

"$BINARY" validate-genesis --home "$HOME_DIR"

echo ">>> Copy resulting config into ./config/ for docker-compose ..."
mkdir -p "$ROOT_DIR/config"
cp "$HOME_DIR/config/genesis.json"          "$ROOT_DIR/config/genesis.json"
cp "$HOME_DIR/config/priv_validator_key.json" "$ROOT_DIR/config/priv_validator_key.json"
cp "$HOME_DIR/config/node_key.json"        "$ROOT_DIR/config/node_key.json"
# addrbook.json may not exist on first init, create empty one if missing
if [ -f "$HOME_DIR/config/addrbook.json" ]; then
  cp "$HOME_DIR/config/addrbook.json"        "$ROOT_DIR/config/addrbook.json"
else
  echo '{"addrs":[]}' > "$ROOT_DIR/config/addrbook.json"
fi

echo ">>> Sync keys into ./data/ home used by docker-compose ..."
mkdir -p "$ROOT_DIR/data/config"
cp "$ROOT_DIR/config/priv_validator_key.json" "$ROOT_DIR/data/config/priv_validator_key.json"
cp "$ROOT_DIR/config/node_key.json"           "$ROOT_DIR/data/config/node_key.json"

echo
echo "Done."
echo "Validator wallet:  $VALIDATOR_KEY_NAME -> $VAL_ADDR"
echo "Community wallet:  $COMMUNITY_KEY_NAME -> $COMM_ADDR"
echo
echo "Now you can start the node with:"
echo "  docker compose up -d"

