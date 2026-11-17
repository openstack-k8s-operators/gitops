# openstack-operator deployment component

Deploys the Red Hat OpenStack Services on OpenShift (RHOSO) `openstack-operator`
through a plain OLM `Subscription`, **without pinning a CatalogSource image to a
specific OpenShift version** and **without pinning the operator CSV**
(`spec.startingCSV` is intentionally absent).

## Requirements

- An **entitled/subscribed OpenShift cluster** with a healthy built-in
  `redhat-operators` CatalogSource in the `openshift-marketplace` namespace:

  ```bash
  oc get catalogsource redhat-operators -n openshift-marketplace
  ```

- On **disconnected** clusters, the mirror of `redhat-operators` must include
  the `openstack-operator` package (see the RHOSO documentation on mirroring
  operator catalogs for restricted networks).

Because the component references the cluster's own `redhat-operators` catalog,
the operator version resolved by OLM always matches what the cluster's catalog
offers for the `stable-v1.0` channel — there is no `redhat-operator-index:vX.Y`
image reference to drift from the cluster version.

## What it deploys

| Resource | Notes |
|----------|-------|
| `Namespace/openstack-operators` | OLM namespace for the Subscription |
| `Namespace/openstack` | `privileged` pod security, no label sync |
| `OperatorGroup/openstack` | AllNamespaces install mode |
| `Subscription/openstack` | channel `stable-v1.0`, `installPlanApproval: Manual`, **no `startingCSV`** |

Note: `installPlanApproval: Manual` means InstallPlans must be approved — either
manually or with the `components/utilities/approve-installplan` component (as
`example/openstack-operator` does).

When consumed through the [rhoso-gitops validated pattern][rhoso-gitops], the
pattern's overrides delete the Namespaces and the OperatorGroup from this
component (they are managed by the pattern's ClusterGroup chart and by OLM's
AllNamespaces mode respectively) — only the Subscription survives.

## Usage

From a sibling path in this repository (as `example/openstack-operator` does):

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
components:
  - ../../components/dependencies/openstack-operator
```

Or remotely, pinned to a ref of this repository:

```yaml
components:
  - https://github.com/openstack-k8s-operators/gitops/components/dependencies/openstack-operator?ref=v0.3.5
```

## Patching

### Pin the operator version

This component is unpinned by design. To pin to a specific CSV, add a patch
targeting the Subscription instead of re-introducing the former
`pin-version`/`olm-values` machinery:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
components:
  - ../../components/dependencies/openstack-operator
patches:
  - target:
      kind: Subscription
      name: openstack
    patch: |-
      - op: add
        path: /spec/startingCSV
        value: "openstack-operator.v1.0.16"
```

Remember that `spec.startingCSV` is a **floor, not a ceiling**: if the catalog
contains a newer CSV in the same channel, OLM resolves to the newer one.

### Use a different catalog or channel

Same mechanism — patch the Subscription fields:

```yaml
patches:
  - target:
      kind: Subscription
      name: openstack
    patch: |-
      - op: replace
        path: /spec/channel
        value: "alpha"
      - op: replace
        path: /spec/source
        value: "my-mirrored-catalog"
      - op: replace
        path: /spec/sourceNamespace
        value: "openshift-marketplace"
```

### Local overlay

For more involved changes (extra resources, different approval mode), create a
local overlay that composes this component instead of copying it, so upstream
fixes still flow in:

```
my-overlay/
├── kustomization.yaml   # components: ../components/dependencies/openstack-operator + patches
└── ...
```

Consumers deploying through ArgoCD can equivalently use the Application's
`spec.source.kustomize.patches` — that is how the rhoso-gitops validated
pattern adjusts this component's resources without forking.

[rhoso-gitops]: https://github.com/validatedpatterns-sandbox/rhoso-gitops
