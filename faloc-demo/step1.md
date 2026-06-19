# Step 1 — Deploy the app, then attack the *unprotected* cluster

The lab files are in `/root/demo`. Move there:

```bash
cd /root/demo
```{{exec}}

Deploy the app — an intentionally-insecure Next.js-style server-action endpoint:

```bash
kubectl apply -f vulnerable-app.yaml
```{{exec}}

```bash
kubectl -n shop rollout status deploy/nextshop
```{{exec}}

Confirm it's serving:

```bash
curl -s http://localhost:30080/ | head -5
```{{exec}}

You should see the **NextShop** page. The interesting endpoint is `POST /api/action`: it imitates a Next.js Server Action (note the `next-action` header it expects) and, for this demo, runs whatever command it receives. That stands in for the code-execution an attacker gets from a real RCE such as CVE-2025-55182 — without shipping a real exploit.

> Use the top-right traffic/port menu in Killercoda to open port **30080** in a browser if you want to see the page.

First, check the pod's CPU usage in the normal case — note how little it uses:

```bash
kubectl -n shop top pod
```{{exec}}

Now attack it **before any defenses are in place** — one crafted POST that makes the pod spawn a shell, drop a vulnearble `workload` into `/tmp`, and run it:

```bash
./attack.sh
```{{exec}}

Watch the simulated payload eat the CPU. With nothing watching, it just keeps running:

```bash
watch -n 2 kubectl -n shop top pod
```{{exec}}

You'll see CPU climb and stay high — the cluster is now running attacker payload. Press `Ctrl+C` to stop watching once the spike is obvious.

> This is the "before" picture: an application RCE turned into a running unauthorized payload, and nothing detected or stopped it. In the next steps we add detection and response, then attack again.
