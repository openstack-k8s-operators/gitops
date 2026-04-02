# External Secrets Operator

Subscribe to External Secrets Operator on OpenShift via Operator Lifecycle Manager (OLM).

## Layout

Manifests live under [`components/secrets/external-secrets-operator/`](../../components/secrets/external-secrets-operator/) in this repository. The `resources/` paths here are thin entrypoints for `oc apply -k` and Argo CD.

- **`components/.../community/`** — default install: a single `Subscription` in `openshift-operators` from the **community-operators** catalog (`spec.channel: stable`). Implemented as a `kind: Component` so the **`redhat/`** overlay can compose it without kustomize path cycles.
- **`components/.../redhat/`** — overlay that includes `community` as a component, adds Namespace `external-secrets-operator` and an `OperatorGroup`, and applies a **JSON6902** patch to the community `Subscription` so it targets the Red Hat catalog (`openshift-external-secrets-operator`, `redhat-operators`, `stable-v1`), including `metadata.name` / `metadata.namespace` and stripping `metadata.labels`. Strategic merge does not reliably change Subscription identity fields; use RFC6902 for those edits.

## Choose one catalog

Do **not** install both the community OperatorHub package and the Red Hat External Secrets Operator on the same cluster. If you switch from one to the other, uninstall the existing operator first (see [Red Hat documentation](https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/security_and_compliance/external-secrets-operator-for-red-hat-openshift)).

## Apply

**Community (default):**

```shell
oc apply -k resources/external-secrets-operator
```

**Red Hat** (requires OpenShift 4.20+ and the `redhat-operators` catalog):

```shell
oc apply -k resources/external-secrets-operator/redhat
```

## Argo CD

Point `spec.source.path` at:

- `resources/external-secrets-operator` for the default (community) manifest, or
- `resources/external-secrets-operator/redhat` for the Red Hat operator.

Use pinned revisions and mirror the pattern in [`applications/external-secrets-operator.yaml`](https://github.com/openstack-k8s-operators/gitops/blob/feature/rhoso-apps-helm-chart/applications/external-secrets-operator.yaml) or [`applications/external-secrets-operator-redhat.yaml`](https://github.com/openstack-k8s-operators/gitops/blob/feature/rhoso-apps-helm-chart/applications/external-secrets-operator-redhat.yaml) (sync-wave, repo URL, `targetRevision`, `kustomize.components` with `?ref=` on remote component URLs).

## Consuming as a component (remote)

From another repo, reference the same content as `components` or `resources` with a **pinned** `ref` (use your branch or tag instead of `feature/rhoso-apps-helm-chart` after merge):

- Community (Component): `https://github.com/openstack-k8s-operators/gitops/components/secrets/external-secrets-operator/community?ref=feature/rhoso-apps-helm-chart`
- Red Hat (Kustomization base; include under `resources:`): `https://github.com/openstack-k8s-operators/gitops/components/secrets/external-secrets-operator/redhat?ref=feature/rhoso-apps-helm-chart`

See also [`components/secrets/README.md`](../../components/secrets/README.md).

## Links

- [External Secrets Operator for Red Hat OpenShift](https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/security_and_compliance/external-secrets-operator-for-red-hat-openshift) (Red Hat)
- [external-secrets.io](https://external-secrets.io/) (upstream)
