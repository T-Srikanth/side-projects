#!/bin/bash
#
# start.sh
#
# This script starts mitmdump in WireGuard mode with unbuffered output,
# writes all output to a log file (/tmp/mitmwireguard.log),
# waits for the configuration to appear, then extracts it into /config/wg0.conf.
#
# Make sure that /config is a shared, writable volume.
#

# Ensure Python flushes output immediately.
export PYTHONUNBUFFERED=1

# Remove any existing log file.
rm -f /tmp/mitmwireguard.log

echo "Starting mitmdump with WireGuard mode..."

# Start mitmdump with forced line buffering and redirect all output into a log file.
stdbuf -oL mitmdump --mode wireguard > /tmp/mitmwireguard.log 2>&1 &
MTPID=$!

# Wait (up to 30 seconds) for the log file to contain the expected marker.
timeout=30
elapsed=0
echo "Waiting for mitmdump to output configuration..."
while [ $elapsed -lt $timeout ]; do
    if grep -q "WireGuard server listening" /tmp/mitmwireguard.log; then
        echo "Configuration output detected."
        break
    fi
    sleep 1
    elapsed=$((elapsed+1))
done

if [ $elapsed -eq $timeout ]; then
    echo "Timeout waiting for mitmdump output."
else
    # Extract the configuration block (from the first "[Interface]" line until the dashed separator)
    awk '/^\[Interface\]/{flag=1} flag { if ($0 ~ /^-+/) { exit } else { print } }' /tmp/mitmwireguard.log > /config/wg0.conf
    echo "Configuration captured in /config/wg0.conf:"
    cat /config/wg0.conf
fi

# Keep the mitmdump process running as the container's main process.
wait $MTPID
