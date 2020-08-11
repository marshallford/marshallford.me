---
title: Self-Managed Kubernetes
order: 1
pills:
  - text: homelab
    icon: dot
---
A GitOps controlled Kubernetes cluster for workloads such as Home Assistant (home automation), Keycloak (self-hosted identity provider), Prometheus + Grafana (monitoring), and the UniFi controller (network mgmt). The cluster was "assembled" with k3s (a lightweight distribution of k8s), Calico for network, and CRI-O as the container runtime. Istio's service mesh in tandem with MetalLB provides ingress to the cluster.
