# Step 2 — Install the Falco detection + response stack

Now bring in the defenses. This installs Falco (modern eBPF) with your custom rules, Falcosidekick (UI + forwarding), and the integrated Falco Talon response engine:

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

The miner from step 1 may still be running on the old pod — clean the slate so the next attack is a fresh, monitored run:

```bash
kubectl -n shop rollout restart deploy/nextshop
kubectl -n shop rollout status deploy/nextshop
```{{exec}}

With the cluster now watched, launch the attack again:

```bash
./attack.sh
```{{exec}}

This time Falco is watching every syscall. Next, let's see what it caught.
