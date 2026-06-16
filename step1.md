# Step 1 — Deploy the vulnerable app

The lab files are in `/root/demo`. Move there:

```bash
cd /root/demo
```

Deploy the app — an intentionally-insecure Next.js-style server-action endpoint:

```bash
kubectl apply -f vulnerable-app.yaml
kubectl -n shop rollout status deploy/nextshop
```

Confirm it's serving:

```bash
curl -s http://localhost:30080/ | head -5
```

You should see the **NextShop** page. The interesting endpoint is `POST /api/action`: it imitates a Next.js Server Action (note the `next-action` header it expects) and, for this demo, runs whatever command it receives. That stands in for the code-execution an attacker gets from a real RCE such as CVE-2025-55182 — without shipping a real exploit.

> Use the top-right traffic/port menu in Killercoda to open port **30080** in a browser if you want to see the page.
