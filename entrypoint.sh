#!/bin/sh
# Fly.io requires UDP services to bind to fly-global-services address
# Teeworlds supports bindaddr config natively

# Resolve fly-global-services
FLY_GLOBAL=$(getent hosts fly-global-services 2>/dev/null | awk '{print $1}')

if [ -n "$FLY_GLOBAL" ]; then
    echo "[entrypoint] Fly.io detected, binding to $FLY_GLOBAL:8303"
    exec ./teeworlds_srv "bindaddr $FLY_GLOBAL"
else
    echo "[entrypoint] Running locally"
    exec ./teeworlds_srv
fi
