# Step 5 — Forensics with Falco capture + Stratoshark

The cleanest forensics path needs no manual `sysdig` at all: **Falco records the `.scap` itself** the moment a rule fires (Falco 0.42+, enabled in `falco-values.yaml`). The `Shell Spawned In Web Container` rule is flagged `capture: true`, so the recording starts at the *earliest* sign of the attack and covers the `/tmp` drop, the miner, the mining-pool dial, and Talon's takedown — all in one file, with zero lag and no ephemeral container.

Trigger it by running the attack (if you haven't just now):

```bash
cd /root/demo && ./attack.sh
```{{exec}}

Falco writes the capture inside its own container at `/tmp/falco_<timestamp>_<n>.scap`. Find it:

```bash
POD=$(kubectl -n falco get pod -l app.kubernetes.io/name=falco -o name | head -1)
kubectl -n falco exec "${POD#pod/}" -c falco -- sh -c 'ls -1 /tmp/*.scap'
```{{exec}}

Copy it out to where the Killercoda file browser can reach it:

```bash
SCAP=$(kubectl -n falco exec "${POD#pod/}" -c falco -- sh -c 'ls -1 /tmp/*.scap | head -1')
kubectl -n falco cp "${POD#pod/}:${SCAP}" /root/demo/forensics.scap -c falco
ls -lh /root/demo/forensics.scap
```{{exec}}

**Analyze it in Stratoshark** (the Wireshark for syscalls):

1. Download `forensics.scap` from the Killercoda file browser (left editor panel).
2. Open Stratoshark on your laptop (from `stratoshark.org`) → **File ▸ Open** → `forensics.scap`.
3. Walk the attack with these display filters (click to copy, paste into Stratoshark):

```text
evt.type = execve and proc.cmdline contains xmrig
```{{copy}}

```text
fd.name contains /tmp
```{{copy}}

```text
evt.type = connect and fd.rport = 3333
```{{copy}}

> **Tip for the talk:** capturing on the shell rule means the moment a rule fired is just an event in the file — the `xmrig` execve *is* the instant the miner rule matched. Pre-generate `forensics.scap` before your session and have it open in Stratoshark, so on stage you simply show the recording rather than racing the live capture.
>
> **Fallback:** if the capture feature misbehaves on the day, `./capture.sh`{{exec}} still does the same thing the old way (node-side sysdig orchestrating the attack into a capture window).
