#!/usr/bin/env bash
# Helper script to show key info from mnemonic (without adding to keyring)
# Usage: ./scripts/show-key-info.sh "<mnemonic phrase>"

if [ -z "$1" ]; then
  echo "Usage: $0 \"<mnemonic phrase>\""
  exit 1
fi

MNEMONIC="$1"
BINARY="${BINARY:-./build/namid}"

if [ ! -x "$BINARY" ]; then
  echo "Binary $BINARY not found. Build it first with: make build"
  exit 1
fi

TMP_HOME=$(mktemp -d)
trap "rm -rf $TMP_HOME" EXIT

echo "Recovering key from mnemonic..."
echo "$MNEMONIC" | "$BINARY" keys add temp-key \
  --recover \
  --keyring-backend test \
  --home "$TMP_HOME" \
  --algo "eth_secp256k1" \
  --no-backup

echo
echo "Key Information:"
echo "================="
ADDR=$("$BINARY" keys show temp-key -a --keyring-backend test --home "$TMP_HOME")
echo "Cosmos Address (bech32): $ADDR"

# Get EVM address (hex) - need to query or derive
echo
echo "To get EVM address (0x...), you can:"
echo "1. Import this mnemonic into MetaMask"
echo "2. Or use: namid debug addr $ADDR"
