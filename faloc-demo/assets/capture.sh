#!/bin/sh
# =============================================================================
#  capture.sh  --  grab a syscall capture (.scap) of the shop namespace for
#  forensic replay in Stratoshark. Run this, THEN run the attack in another
#  pane; the .scap will contain the full shell + dropper + miner sequence.
#
#  Two ways to produce a .scap:
#    (A) sysdig CLI on the node  (used below -- simplest for a live demo)
#    (B) Falco's capture-on-rule-fire feature, which auto-writes a .scap the
#        moment a rule trips (newer Falco) -- mention this on stage as the
#        "production" path.
# =============================================================================

OUT="${1:-/root/demo/forensics.scap}"
SECS="${2:-30}"

# Install sysdig OSS on the node if it isn't present.
if ! command -v sysdig >/dev/null 2>&1; then
  echo "[*] Installing sysdig OSS ..."
  curl -s https://download.sysdig.com/stable/install-sysdig | bash
fi

echo "[*] Capturing syscalls for ${SECS}s -> ${OUT}"
echo "[*] Now run ./attack.sh in another terminal pane."
# Scope the capture to the demo namespace to keep the file small and focused.
sysdig -w "$OUT" -M "$SECS" "k8s.ns.name=shop" || \
  sysdig -w "$OUT" -M "$SECS" "container.name contains nextshop"

echo
echo "[*] Capture written to ${OUT}"
echo "[*] Download it from the Killercoda file browser, then open in Stratoshark:"
echo "      - File > Open  ->  forensics.scap"
echo "      - Filter examples:"
echo "          proc.name = workload-sim"
echo "          evt.type = execve"
echo "          fd.name contains /tmp"
echo "          evt.type in (connect, sendto) and fd.dport = 8444"
