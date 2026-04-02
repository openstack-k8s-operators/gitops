# Vault Secrets Operator

Subscribe to the Vault Secrets Operator on OpenShift.

The subscription manifest lives under [`components/secrets/vault-secrets-operator/`](../../components/secrets/vault-secrets-operator/) in this repository. This `resources/` directory is a thin wrapper for `oc apply -k` and Argo CD (`applications/vault-secrets-operator.yaml`).

## Consuming as a component (remote)

Pin a Git revision (replace `BRANCH` with your branch or tag):

`https://github.com/openstack-k8s-operators/gitops/components/secrets/vault-secrets-operator?ref=BRANCH`

See [`components/secrets/README.md`](../../components/secrets/README.md).
