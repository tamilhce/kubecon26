# Step 2 — Install Falco, then attack

Install the whole detection + response stack in one command — Falco (modern eBPF) with your custom rules, Falcosidekick (UI + forwarding), and the integrated Falco Talon response engine:

```bash
cd /root/demo
helm install falco falcosecurity/falco -n falco --create-namespace \
  -f falco-values.yaml \
  --set-file customRules."custom-rules\.yaml"=custom-rules.yaml
```{{exec}}

```bash
kubectl -n falco rollout status ds/falco
```{{exec}}

Wait until Falco, Falcosidekick, and Talon are all running:

```bash
kubectl -n falco get pods
```{{exec}}

Now launch the simulated attack — one crafted POST that makes the pod spawn a shell, drop a fake `xmrig` into `/tmp`, and run it:

```bash
./attack.sh
```{{exec}}

Watch the miner burn CPU on the pod (metrics-server is pre-installed):

```bash
kubectl -n shop top pod
```{{exec}}

The CPU spike is the visible "damage." Next, let's see what Falco caught.
