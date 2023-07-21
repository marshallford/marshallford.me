---
title: Self-Managed Kubernetes
order: 1
pills:
  - text: homelab
    icon: dot-circle
---
GitOps managed k3s cluster deployed with Terraform and Ansible -- designed to replicate the UX of managed/cloud k8s offerings. Highly available control plane via HAProxy, Keepalived, and mock AZs. Services utilized include: Cilium for CNI, MetalLB for LBs, Istio for Ingress, Keycloak as an IdP, Prometheus and Grafana for monitoring, Rook Ceph for persistence, and OPA Gatekeeper for policy enforcement.
