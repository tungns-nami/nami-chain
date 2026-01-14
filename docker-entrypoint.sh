#!/bin/bash
set -e

HOME_DIR="/root/.namid"
DATA_DIR="${HOME_DIR}/data"
CONFIG_DIR="${HOME_DIR}/config"

mkdir -p "${DATA_DIR}"

if [ ! -f "${DATA_DIR}/priv_validator_state.json" ]; then
    echo "Node not initialized. Initializing..."
    
    if [ -d "${CONFIG_DIR}" ] && [ -f "${CONFIG_DIR}/genesis.json" ]; then
        echo "Using existing config from host..."
        cat > "${DATA_DIR}/priv_validator_state.json" <<INNEREOF
{
  "height": "0",
  "round": 0,
  "step": 0
}
INNEREOF
        echo "Created priv_validator_state.json"
    else
        MONIKER="${MONIKER:-namitestnet}"
        CHAIN_ID="${CHAIN_ID:-nami_101012026-1}"
        echo "Initializing node with moniker=${MONIKER} and chain-id=${CHAIN_ID}..."
        namid init "${MONIKER}" --chain-id "${CHAIN_ID}" --home "${HOME_DIR}" || true
    fi
else
    echo "Node already initialized. Skipping init step."
fi

exec "$@"
