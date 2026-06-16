#!/bin/bash
# Runs once when the scenario starts (before step 1). Pre-stages the slow bits
# so the live demo stays snappy. Output is hidden from the participant.
mkdir -p /root/demo

# Wait for the single-node cluster to be ready.
until kubectl get nodes 2>/dev/null | grep -q ' Ready'; do sleep 3; done

# Helm + the Falco chart repo.
if ! command -v helm >/dev/null 2>&1; then
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi
helm repo add falcosecurity https://falcosecurity.github.io/charts >/dev/null 2>&1
helm repo update >/dev/null 2>&1

# metrics-server so `kubectl top` shows the miner's CPU spike (insecure-tls for
# the self-signed kubelet certs on a kubeadm lab node).
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml >/dev/null 2>&1
kubectl -n kube-system patch deploy metrics-server --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]' >/dev/null 2>&1

# Pre-pull the app image so step 1 starts in seconds.
ctr -n k8s.io images pull docker.io/library/node:20-alpine >/dev/null 2>&1 || true

touch /root/demo/.ready
