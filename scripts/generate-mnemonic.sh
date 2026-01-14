#!/usr/bin/env bash
# Helper script to generate a new mnemonic for Nami chain
# Usage: ./scripts/generate-mnemonic.sh [key-name]

KEY_NAME="${1:-new-key}"
BINARY="${BINARY:-./build/namid}"

if [ ! -x "$BINARY" ]; then
  echo "Binary $BINARY not found. Build it first with: make build"
  exit 1
fi

echo "Generating new mnemonic for key: $KEY_NAME"
echo "----------------------------------------"
echo

# Create a temporary home directory
TMP_HOME=$(mktemp -d)
trap "rm -rf $TMP_HOME" EXIT

# Generate new key (this will print the mnemonic)
"$BINARY" keys add "$KEY_NAME" \
  --keyring-backend test \
  --home "$TMP_HOME" \
  --algo "eth_secp256k1" \
  --output json 2>&1 | grep -A 20 "mnemonic\|Important" || \
"$BINARY" keys add "$KEY_NAME" \
  --keyring-backend test \
  --home "$TMP_HOME" \
  --algo "eth_secp256k1"

echo
echo "----------------------------------------"
echo "✅ Mnemonic generated!"
echo
echo "To use this mnemonic in .env, add:"
echo "VALIDATOR_MNEMONIC=\"<paste mnemonic here>\""
echo "or"
echo "COMMUNITY_MNEMONIC=\"<paste mnemonic here>\""
