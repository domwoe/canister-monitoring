#!/bin/bash

rm -rf .dfx
dfx start --background --clean
# Wait
sleep 90
dfx deploy
CANISTER_ID=$(dfx canister id expose_metrics)
TARGET=${CANISTER_ID}.canister:8000

echo "[{\"targets\": [\"${TARGET}\"], \"labels\": {\"job\": \"canister_metrics\"}}]" > /prometheus/prometheus_target.json
# Keep on doing something. Otherwise the container will be killed
tail -f /dev/null