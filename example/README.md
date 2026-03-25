# Examples

Sample overlays that consume this repository’s Kustomize components. Directory names match
the **###** headings under *Application responsibilities and content* in the root
`README.md`.

Run `kustomize build` in each directory to render manifests (and sync-wave annotations
where the overlay includes `components/argocd/annotations`).

## Applications (per root README)

| Directory | Role |
| --------- | ---- |
| [openstack-operator](./openstack-operator/) | Foundational OpenStack operators: CDN catalog + pinned CSV, OLM subscription from `architecture` `olm-openstack-subscriptions`, InstallPlan approval Job, RBAC. |
| [openstack-operator-cr](./openstack-operator-cr/) | Main `OpenStack` custom resource in `openstack-operators`. |
| [openstack-networks](./openstack-networks/) | Underlying networks: NNCP, NAD, NetConfig, MetalLB pools / advertisements, etc. |
| [openstack-controlplane](./openstack-controlplane/) | `OpenStackControlPlane` and optional watcher service (networking is a separate overlay). |
| [openstack-dataplane](./openstack-dataplane/) | Data plane node set and deployment. |

## Prerequisites (not named in *Application responsibilities*)

These are called out separately in the root `README.md` (for example *What’s NOT covered
by ArgoCD applications yet* or operator install procedures).

| Directory | Role |
| --------- | ---- |
| [dependencies](./dependencies/) | OLM-related dependencies from the architecture repo (MetalLB, NMState, cert-manager, etc. are not modeled as Argo CD Applications here yet). |

To deploy the Vault Secrets Operator via Argo CD, see the root `README.md` and
`applications/vault-secrets-operator.yaml`.
