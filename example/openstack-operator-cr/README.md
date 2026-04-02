# openstack-operator-cr

Example overlay for the **openstack-operator-cr** application described in the root
`README.md` under *Application responsibilities and content*.

This directory applies a minimal **OpenStack** custom resource in the
`openstack-operators` namespace. It is the primary configuration object for the overall
OpenStack deployment on the cluster (see product documentation for full `spec` options).

## Render

From this directory:

```shell
kustomize build .
```

## Layout

| File | Role |
| ---- | ---- |
| `openstack.yaml` | `OpenStack` CR (`operator.openstack.org/v1beta1`) |
| `kustomization.yaml` | Sets namespace and includes the CR |
