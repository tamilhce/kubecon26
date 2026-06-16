# Step 5 — Forensics with sysdig + Stratoshark

An alert says *something* happened. A syscall capture says *exactly* what happened, in order. Let's record one and replay it.

Start a 30-second capture scoped to the `shop` namespace:

```bash
cd /root/demo
./capture.sh /root/demo/forensics.scap 30
```{{exec}}

While it runs, open a **second terminal tab** (the `+` in the terminal bar) and fire the attack so it lands inside the capture window:

```bash
cd /root/demo && ./attack.sh
```{{exec}}

When `capture.sh` finishes you have `/root/demo/forensics.scap` — a complete record of the shell, the `/tmp` write, the `execve` of `xmrig`, and the network attempt.

**Analyze it in Stratoshark** (the Wireshark for syscalls):

1. Download `forensics.scap` from the Killercoda file browser (left editor panel).
2. Open Stratoshark on your laptop (from `stratoshark.org`) → **File ▸ Open** → `forensics.scap`.
3. Reconstruct the attack with these display filters (click to copy, then paste into Stratoshark):

```text
evt.type = execve and proc.cmdline contains xmrig
```{{copy}}

```text
fd.name contains /tmp
```{{copy}}

```text
evt.type = connect and fd.dport = 3333
```{{copy}}

> **Production path to mention on stage:** newer Falco can auto-write a `.scap` the instant a rule fires (capture-on-detection), so the forensic snapshot exists *before* Talon even terminates the pod — closing the gap between alert and evidence with zero manual steps.
