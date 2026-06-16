# Stopping a Crypto-Mining Attack in Kubernetes

A single application RCE can turn your cluster into someone else's money printer. In this hands-on lab you will:

1. **Deploy** a deliberately-vulnerable web app.
2. **Simulate** the post-exploit: a shell spawns, a "miner" drops into `/tmp`, and it dials a mining-pool port.
3. **Detect** it at runtime with **Falco**, viewing alerts in **Falcosidekick**.
4. **Respond** automatically with **Falco Talon** — label the pod, capture traffic, and terminate it.
5. **Investigate** with a **sysdig** syscall capture replayed in **Stratoshark**.

> **Safety note.** Everything here is a harmless simulation. The "vulnerability" is an intentional teaching endpoint, and the "miner" only spins CPU briefly and pokes one unroutable address — it mines nothing and contacts no real pool. Run this only in this isolated lab.

All files are in `/root/demo`. The cluster, Helm, and the Falco chart repo are set up for you in the background — give it a few seconds when you start.
