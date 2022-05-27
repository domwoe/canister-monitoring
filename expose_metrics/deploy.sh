#!/bin/bash

rm -fr .dfx
dfx start --clean --background
dfx deploy
CANISTER_ID=$(dfx canister id expose_metrics)

jq -n \
    --arg id "$CANISTER_ID" \
    '{targets: ["[$id].canister:8000"], labels: {job: "canister_metrics"}}'  > /prometheus/prometheus_target.json