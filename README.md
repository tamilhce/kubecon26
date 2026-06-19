# Next.Js RCE | FALCO | Kubernetes — Killercoda Demo

A hands-on Killercoda scenario for Participants. TO deploy a vulnerable app, simulate a Next.Js  post-exploit, then **detect**
(Falco + Falcosidekick), **respond** (Falco Talon), and **investigate**
(sysdig → Stratoshark).

> **Safety / scope.** Everything here is a *simulation* for an isolated lab.
> The "vulnerability" is an intentional teaching endpoint (DVWA-style command
> exec), not a working exploit for any real CVE. The "miner" only spins CPU for
> ~25s and makes one connect attempt to a reserved, unroutable address — it
> mines nothing and reaches no real pool. Do not deploy the app anywhere
> reachable from an untrusted network. The detection/response/forensics flow is
> byte-for-byte identical to a real attack because Falco watches *behaviour*.

## Repo layout

```
.
├── index.json              # scenario metadata + step list + asset upload
├── background-setup.sh      # runs at start: cluster wait, helm repo, metrics-server
├── intro.md  step1..5.md  finish.md
└── assets/                  # uploaded to /root/demo in the lab
    ├── vulnerable-app.yaml  # ConfigMap(app) + Deployment + NodePort Service (ns: shop)
    ├── attack.sh            # sends the crafted POST that triggers the chain
    ├── fake-miner.sh        # harmless CPU spinner + one mining-port connect
    ├── custom-rules.yaml    # 4 Falco rules: shell / tmp-drop / miner / pool-port
    ├── falco-values.yaml    # Helm values: Falco + Falcosidekick + Talon (inline rules)
    ├── talon-rules.yaml     # readable copy of the Talon rules (embedded in values)
    └── capture.sh           # sysdig .scap capture for Stratoshark
```

## Deploy it on Killercoda

1. Push this folder to a GitHub repo (it can live alongside your existing demo repo).
2. Sign in at killercoda.com, **Create → Scenario from Git**, point it at the repo
   path. A push triggers a webhook and Killercoda re-imports automatically.
3. Open the scenario; the background script stages Helm, the Falco repo, and
   metrics-server while you read the intro.

## Demo flow (≈25 min)

| Step | What happens | Tool |
|---|---|---|
| 1 | Deploy vulnerable `nextshop` app | kubectl |
| 2 | Install Falco stack, run `./attack.sh`, see CPU spike | Helm, Falco |
| 3 | Four rules fire; browse events in the UI | Falcosidekick |
| 4 | Pod labelled, captured, terminated automatically | Falco Talon |
| 5 | Record a `.scap`, replay the attack offline | sysdig + Stratoshark |

## Notes & troubleshooting (version-sensitive bits)

- **Falco chart v6.0.0+** is required for the integrated `falco-talon` subchart.
  Check with `helm search repo falcosecurity/falco --versions`. On older charts,
  install Talon from its own chart (`falcosecurity/falco-talon`) and mount
  `talon-rules.yaml`; point `falcosidekick.config.webhook.address` at its service.
- **Talon service name** in the Falcosidekick webhook is `<release>-falco-talon`
  (`falco-falco-talon` for `helm install falco ...`). If events don't reach Talon,
  run `kubectl -n falco get svc` and adjust `falco-values.yaml`.
- **`k8s.ns.name` in alerts** comes from container metadata; the rules don't
  depend on it for matching (they use `proc.pname`, `fd.name`, ports), so they
  fire even if that field is blank.
- **`kubectl top` empty?** metrics-server needs ~30s after start to populate.
- **Entry vector is simulated by design** — to demo the real deserialization
  mechanism conceptually.
