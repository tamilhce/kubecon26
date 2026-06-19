# Step 3 — Detect with Falco + Falcosidekick

Tail Falco's alerts. The attack should trip four distinct rules:

```bash
kubectl -n falco logs -l app.kubernetes.io/name=falco -c falco --tail=80 | grep -Ei 'shell|tmp|workload|outbound'
```{{exec}}

What each rule caught:

- **Shell Spawned In Web Container** — the node app spawned `/bin/sh`; it never does that normally (rule matches `proc.pname = node`).
- **Executable Dropped In Tmp** — the dropper writing `/tmp/workload-sim`.
- **Suspicious Workload Launched** — the `workload-sim` command line executing.
- **Unexpected Outbound Connection Port** — the connect attempt to port 8444.

Open the **Falcosidekick UI** to see the same events with full Kubernetes context:

```bash
kubectl -n falco port-forward --address 0.0.0.0 svc/falco-falcosidekick-ui 2802:2802 >/dev/null 2>&1 &
```{{exec}}

Then open port **2802** from the Killercoda traffic menu (top-right of the terminal).

> The rules live in `demo/custom-rules.yaml`.
