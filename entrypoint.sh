#!/bin/sh
# Fly.io requires UDP services to bind to fly-global-services address
# Use socat to proxy from fly-global-services:8303 to localhost:8303

# Resolve fly-global-services
FLY_GLOBAL=$(getent hosts fly-global-services | awk '{print $1}')

if [ -n "$FLY_GLOBAL" ]; then
    echo "[entrypoint] Fly.io detected, starting UDP proxy: $FLY_GLOBAL:8303 -> 127.0.0.1:8303"
    socat UDP4-LISTEN:8303,bind=$FLY_GLOBAL,fork,reuseaddr UDP4:127.0.0.1:8303 &
    # Start teeworlds on localhost
    exec ./teeworlds_srv -f autoexec.cfg
else
    echo "[entrypoint] Running locally, starting teeworlds directly"
    exec ./teeworlds_srv -f autoexec.cfg
fi
