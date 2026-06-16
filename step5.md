# Step 5 — Forensics with sysdig + Stratoshark

An alert says *something* happened. A syscall capture says *exactly* what happened, in order. Let's record one and replay it.

Start a 30-second capture scoped to the `shop` namespace:

```bash
cd /root/demo
./capture.sh /root/demo/forensics.scap 30
```

While it runs, open a **second terminal tab** (the `+` in the terminal bar) and fire the attack so it lands inside the capture window:

```bash
cd /root/demo && ./attack.sh
```

When `capture.sh` finishes you have `/root/demo/forensics.scap` — a complete record of the shell, the `/tmp` write, the `execve` of `xmrig`, and the network attempt.

**Analyze it in Stratoshark** (the Wireshark for syscalls):

1. Download `forensics.scap` from the Killercoda file browser (left editor panel).
2. Open Stratoshark on your laptop (from `stratoshark.org`) → **File ▸ Open** → `forensics.scap`.
3. Reconstruct the attack with display filters:

```text
evt.type = execve and proc.cmdline contains xmrig
fd.name contains /tmp
evt.type = connect and fd.dport = 3333
```

> **Production path to mention on stage:** newer Falco can auto-write a `.scap` the instant a rule fires (capture-on-detection), so the forensic snapshot exists *before* Talon even terminates the pod — closing the gap between alert and evidence with zero manual steps.
