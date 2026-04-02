# Secrets operator components

Kustomize `Component` and overlay bases for Vault Secrets Operator (VSO) and External Secrets Operator (ESO). The matching [`resources/`](../../resources/) paths are thin wrappers so you can install from this repo with `oc apply -k resources/...` or compose only the component from another repository.

Pin a Git revision on remote URLs (replace `BRANCH` with your branch or tag):

- VSO: `https://github.com/openstack-k8s-operators/gitops/components/secrets/vault-secrets-operator?ref=BRANCH`
- ESO (community catalog): `https://github.com/openstack-k8s-operators/gitops/components/secrets/external-secrets-operator/community?ref=BRANCH`
- ESO (Red Hat overlay): use as a **base** (not `kind: Component`): `https://github.com/openstack-k8s-operators/gitops/components/secrets/external-secrets-operator/redhat?ref=BRANCH`

Example overlay `kustomization.yaml` (VSO):

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources: []
components:
  - https://github.com/openstack-k8s-operators/gitops/components/secrets/vault-secrets-operator?ref=feature/rhoso-apps-helm-chart
```

Example including the Red Hat ESO overlay as a resource:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - https://github.com/openstack-k8s-operators/gitops/components/secrets/external-secrets-operator/redhat?ref=feature/rhoso-apps-helm-chart
```
