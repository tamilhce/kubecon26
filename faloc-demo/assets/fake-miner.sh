#!/bin/sh
# =============================================================================
#  fake-miner.sh  --  HARMLESS SIMULATION. Runs INSIDE the app container.
#  Named "workload-sim" once dropped, so logs/captures look realistic. It:
#    * prints an workload-sim-style banner            -> realistic Falcosidekick output
#    * makes ONE outbound attempt to port 8444 -> trips the mining-pool rule
#      on 198.51.100.1 (reserved TEST-NET-2, unroutable -> goes nowhere)
#    * pegs one CPU core for ~25s then exits    -> visible spike, self-cleaning
#
# =============================================================================
echo " * POOL tcp://198.51.100.1:8444 (reserved TEST-NET-2, unroutable)"

# Outbound attempt to a vunlerable-pool-style port. busybox wget exists in Alpine;
# it issues a connect() to :8444 that Falco sees even though it never connects.
wget -T 2 -q -O /dev/null "http://198.51.100.1:8444/" 2>/dev/null || true
command -v nc >/dev/null 2>&1 && (printf '' | nc -w 2 198.51.100.1 8444) 2>/dev/null || true

echo " * CPU     spinning for ~25s to generate a load spike"
timeout 25 sh -c 'while :; do :; done' 2>/dev/null || true
echo " * vulnerable workload exited (demo window over)"
