#!/bin/sh
# =============================================================================
#  fake-miner.sh  --  HARMLESS SIMULATION. Runs INSIDE the app container.
#  Named "xmrig" once dropped, so logs/captures look realistic. It:
#    * prints an xmrig-style banner            -> realistic Falcosidekick output
#    * makes ONE outbound attempt to port 3333 -> trips the mining-pool rule
#      on 198.51.100.1 (reserved TEST-NET-2, unroutable -> goes nowhere)
#    * pegs one CPU core for ~25s then exits    -> visible spike, self-cleaning
#  It mines NOTHING and reaches NO real pool. Isolated lab use only.
# =============================================================================
echo " * ABOUT   XMRig 6.x (SIMULATED - demo only, mines nothing)"
echo " * POOL    stratum+tcp://198.51.100.1:3333 (reserved TEST-NET-2, unroutable)"

# Outbound attempt to a mining-pool-style port. busybox wget exists in Alpine;
# it issues a connect() to :3333 that Falco sees even though it never connects.
wget -T 2 -q -O /dev/null "http://198.51.100.1:3333/" 2>/dev/null || true
command -v nc >/dev/null 2>&1 && (printf '' | nc -w 2 198.51.100.1 3333) 2>/dev/null || true

echo " * CPU     spinning for ~25s to generate a load spike"
timeout 25 sh -c 'while :; do :; done' 2>/dev/null || true
echo " * miner exited (demo window over)"
