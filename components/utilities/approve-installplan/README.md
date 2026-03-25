# approve-installplan

Kustomize `Component` that adds:

- `ClusterRole` / `ClusterRoleBinding` so the OpenShift GitOps Argo CD application controller can patch `InstallPlan` objects and read related OpenStack APIs used by the Job script.
- `Job` `approve-openstack-installplan` (sync-wave `1`) that approves a Manual InstallPlan and waits for operator install.
- JSON6902 patch on `Subscription` named `openstack` (sync-wave `0`), matching
  [`architecture` `olm-openstack-subscriptions`](https://github.com/openstack-k8s-operators/architecture/tree/main/lib/olm-openstack-subscriptions).

## Usage

List this directory under `components` **after** the overlay that emits the `Subscription` (for
example the remote `lib/olm-openstack-subscriptions/overlays/default` component). If this component
runs first, the Subscription sync-wave patch will not apply.

```yaml
components:
  - pin-version
  - https://github.com/openstack-k8s-operators/architecture/lib/olm-openstack-subscriptions/overlays/default?ref=COMMIT_SHA
  - https://github.com/openstack-k8s-operators/gitops/components/utilities/approve-installplan?ref=v0.1.0
```

Images: `registry.redhat.io/openshift4/ose-tools-rhel9:latest` (Job).

In-tree overlays may reference this component with a local path until a release tag that contains
`components/utilities/approve-installplan` is published; use the HTTPS URL above for reproducible
builds outside the repository.
