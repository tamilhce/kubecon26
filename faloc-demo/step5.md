# Step 5 — Forensics with Falco capture + Stratoshark

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
evt.type = execve and proc.cmdline contains workload-sim
```{{copy}}

```text
fd.name contains /tmp
```{{copy}}

```text
evt.type = connect and fd.rport = 8444
```{{copy}}

