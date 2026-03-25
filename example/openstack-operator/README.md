# openstack-operator

Sample Kustomize overlay for the **openstack-operator** application described in the repository root
`README.md` under *Application responsibilities and content*.

It installs the OpenStack operator from the **Red Hat Operator Hub** (`redhat-operators` catalog):
namespaces, `OperatorGroup`, `CatalogSource`, `Subscription` with a pinned `startingCSV`, Manual
InstallPlan approval, a post-sync `Job` that approves the InstallPlan, and RBAC for the OpenShift
GitOps application controller. The OLM manifests are composed from the
[`openstack-k8s-operators/architecture`](https://github.com/openstack-k8s-operators/architecture)
`lib/olm-openstack-subscriptions` component; local pieces supply CDN catalog settings and the CSV
pin.

See Red Hat documentation:
[Installing and preparing the OpenStack operator](https://docs.redhat.com/en/documentation/red_hat_openstack_services_on_openshift/18.0/html/deploying_red_hat_openstack_services_on_openshift/assembly_installing-and-preparing-the-openstack-operator).

## Layout

| Path | Role |
| ---- | ---- |
| `catalog/values.yaml` | `ConfigMap` `olm-values` (channel, `redhat-operators`, index image, Manual approval) |
| `pin-version/` | Adds `data.openstack-operator-version` for `spec.startingCSV` |
| Remote component | `architecture` `olm-openstack-subscriptions/overlays/default` (pinned git ref in `kustomization.yaml`) |
| [approve-installplan](https://github.com/openstack-k8s-operators/gitops/tree/v0.1.0/components/utilities/approve-installplan) (`?ref=v0.1.0`) | Shared utility: RBAC, InstallPlan approval `Job`, Subscription sync-wave |

Component order in `kustomization.yaml` matters: the version pin runs before the remote OLM
component; the approval `Component` runs after it so the Subscription exists when the sync-wave patch
is applied.

## Render

From the repository root (network access is required the first time to fetch the remote component):

```bash
kustomize build example/openstack-operator
```

## Tunables

- **`registry.redhat.io/redhat/redhat-operator-index` tag** in `catalog/values.yaml` (`openstack-operator-image`):
  use an index tag that matches your OpenShift cluster version (for example `v4.18` on OpenShift 4.18).
- **`openstack-operator.v1.0.16`** in `pin-version/patch.yaml`: adjust the CSV string when you target
  a different RHOSO release available in the catalog.
- **Remote `architecture` git ref** in `kustomization.yaml`: pinned to a commit SHA for reproducible
  builds; bump when you intentionally adopt newer `lib/olm-openstack-subscriptions` behavior.

Clusters must be able to pull images from `registry.redhat.io` (pull secret / global pull secret).

## Related

- [`components/utilities/`](../../components/utilities/) for shared helper components (including InstallPlan approval).
- `openstack-operator-cr` example: main `OpenStack` CR (separate overlay).
- `example/dependencies` for other OLM-related dependencies (MetalLB, NMState, cert-manager, etc.).
