#!/bin/bash

rm -rf .dfx
dfx start --background --clean
# Wait because otherwise deploy will run befofe the replica is up
# This is only necessary if used on M1 macs because the container
# runs in emulation
if [[ $(uname -m) == "x86_64" ]]; then 
    sleep 120
fi
dfx deploy
CANISTER_ID=$(dfx canister id expose_metrics)

# You might want to use this if you deploy to the Internet Computer
# TARGET=${CANISTER_ID}.ic0.app
# echo "[{\"targets\": [\"${TARGET}\"], \"labels\": {\"job\": \"canister_metrics\"}}]" > /prometheus/prometheus_target.json

# Use nginx to inject canister id because subdomains on localhost do not work properly
cat <<EOT > /etc/nginx/sites-available/canister.conf 
server {
    listen 80;
    location / {
        rewrite ^(.*)$ \$1?canisterId=${CANISTER_ID} break;
        proxy_pass http://localhost:8000;
    }
}
EOT

unlink /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/canister.conf /etc/nginx/sites-enabled/canister.conf
service nginx restart

# Keep on doing something. Otherwise the container will be killed
tail -f /dev/null