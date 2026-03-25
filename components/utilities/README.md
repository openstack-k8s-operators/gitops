# Utilities

Shared Kustomize `Component` helpers for GitOps overlays. Add new utilities as subdirectories
here (each subdirectory should contain a `kustomization.yaml` with `kind: Component`).

| Component | Role |
| --------- | ---- |
| [approve-installplan](./approve-installplan/) | RBAC, `Job`, and Subscription sync-wave patch for Manual OLM InstallPlan approval (OpenStack operator subscription from `architecture` `olm-openstack-subscriptions`). |
