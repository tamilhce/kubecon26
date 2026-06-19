# You contained a cluster-wide attack 🎯

In ~15 minutes you ran the full defence-in-depth loop:

- **Deployed** a vulnerable app and **simulated** a post-exploit.
- **Detected** it at runtime with four Falco rules, viewed in Falcosidekick.
- **Responded** automatically with Falco Talon — labelled, captured, and terminated the compromised pod.
- **Investigated** with a sysdig `.scap` capture replayed in Stratoshark.

### The one-line takeaway
Patching closes one door. Falco, Talon, and Stratoshark catch the attacker's **behaviour** — the shell, the `/tmp` drop, the miner, the outbound port — no matter which door they came through. That's why runtime detection + response + forensics matters even on a fully-patched cluster.

### Take it further
- Add Kyverno admission policies (resource limits, no-privileged, read-only rootfs) so the miner can't even get a foothold.
- Wire Falcosidekick to Slack/PagerDuty for real alerting.
- Turn on Falco capture-on-detection for automatic forensic snapshots.

All rules and configs are in `/root/demo` and in the repo — reuse them freely.
