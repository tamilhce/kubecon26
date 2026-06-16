# Step 4 — Respond automatically with Falco Talon

Detection is half the story; Talon turns alerts into action. The rules (embedded in `falco-values.yaml`, mirrored in `talon-rules.yaml`) say:

- **Shell detected** → label the pod `suspicious=true`.
- **Miner or mining-pool port detected** → **terminate the pod** (killing the shell and the miner).

Watch Talon react to the events from the previous step:

```bash
kubectl -n falco logs -l app.kubernetes.io/name=falco-talon --tail=40
```{{exec}}

You should see the `kubernetes:label` and `kubernetes:terminate` actions fire. Confirm the malicious pod was torn down and a clean one replaced it:

```bash
kubectl -n shop get pods -L suspicious
```{{exec}}

Run the attack again and watch the full lifecycle — the compromised pod is killed within seconds of the miner starting:

```bash
./attack.sh ; kubectl -n shop get pods -w
```{{exec}}

That is blast-radius containment: even though the "RCE" succeeded, the attacker's foothold lasts only seconds. Press `Ctrl+C` to stop watching.

> To kill **only** the shell process instead of the whole pod, uncomment the `Kill Shell` (`kubernetes:exec`) action in `talon-rules.yaml` and bind it to the shell rule. Talon hot-reloads rules.
