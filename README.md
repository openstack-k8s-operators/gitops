# Deploying and managing Red Hat OpenStack Services on OpenShift with GitOps

This repository contains an implementation of Red Hat GitOps (GitOps, ArgoCD) for managing the
deployment of Red Hat OpenStack Services on OpenShift (RHOSO).

**WARNING**: _This repository is provided as a Developer Preview for testing environments only, 
before all features have been implemented and tested. Therefore, some functionality may be absent, 
incomplete, or not work as expected, and is subject to change until the official release. 
Red Hat encourages customers to use the Developer Preview release to provide feedback._

## Prerequisites: Use pinned resources

In your `kustomization.yaml` and related resources, make sure to use
a fixed reference `?ref=VALUE`, where `VALUE` is a hash or a tag.

## Deploy the OpenShift GitOps Operator

### Option 1: Deploy automatically with the included helper playbook
We provide a light playbook to facilitate the operator deployment and
subsequent ArgoCD instance configuration.

[Read the playbook documentation](./openshift-gitops.deploy/README.md).

### Option 2: Deploy manually with `oc apply` commands
1. Create the namespace, operatorgroup and subscription:
    ```shell
    oc apply -k openshift-gitops.deploy/subscribe
    ```
1. Ensure that the namespace is present:
    ```shell
    oc get namespace openshift-gitops
    ```
1. Configure the RBAC and ArgoCD instance:
    ```shell
    oc apply -k openshift-gitops.deploy/enable
    ```
1. Ensure that the ArgoCD instance is running:
    ```shell
    oc -n openshift-gitops get argocd/openshift-gitops
    ```

## Deploy the Vault Secrets Operator (VSO)

HashiCorp Vault is used to store secrets, and VaultStaticSecret are used to
pull those secrets into OCP. 

**Procedure**
1. Create the subscription using ArgoCD:
    ```shell
    oc apply -f applications/vault-secrets-operator.yaml
    ```

**Links**
* [Learn more about VSO](https://developer.hashicorp.com/vault/docs/deploy/kubernetes/vso).
* [VSO on catalog.redhat.com](https://catalog.redhat.com/en/software/containers/hashicorp/vault-secrets-operator-bundle/64ddcd189d40d16b88133fd8)

## ArgoCD orchestration principles

### Sync-waves

We’re using sync-waves annotations for specific jobs and actions.

The range -20;20 is reserved.

### Healthchecks

TBD

## Application responsibilities and content

### openstack-operator

#### Purpose

Installs the foundational OpenStack operators required for the deployment. Covers [Installation Documentation Chapter 1](https://docs.redhat.com/en/documentation/red_hat_openstack_services_on_openshift/18.0/html/deploying_red_hat_openstack_services_on_openshift/assembly_installing-and-preparing-the-openstack-operator) and part of [Installation Documentation Chapter 2](https://docs.redhat.com/en/documentation/red_hat_openstack_services_on_openshift/18.0/html/deploying_red_hat_openstack_services_on_openshift/assembly_preparing-rhocp-for-rhoso#proc_creating-the-openstack-namespace_preparing)

#### Key resources

* **Namespaces:** `openstack`, `openstack-operators`  
* **Operator Subscription:** OpenStack operator from Red Hat CDN  
* **RBAC:** Install plan approver service account and roles  
* **Job:** `approve-openstack-installplan` to "imperatively" accept the `install_plan` created by `OLM` and wait for its completion.

### openstack-operator-cr

#### Purpose

Creates the main OpenStack custom resource that defines the overall OpenStack deployment configuration. Covers [Installation Documentation Chapter 1](https://docs.redhat.com/en/documentation/red_hat_openstack_services_on_openshift/18.0/html/deploying_red_hat_openstack_services_on_openshift/assembly_installing-and-preparing-the-openstack-operator).

#### Key resources

* **OpenStack CR:** Primary configuration object in `openstack-operators` namespace  
* **Example overlay:** [`example/openstack-operator-cr/`](example/openstack-operator-cr/)

### openstack-networks

#### Purpose

Create underlying networks for controlplane and dataplane. Covers [Installation Documentation Chapter 3](https://docs.redhat.com/en/documentation/red_hat_openstack_services_on_openshift/18.0/html/deploying_red_hat_openstack_services_on_openshift/assembly_preparing-rhoso-networks_preparing).

#### Key resources

* [3.2.1. Preparing RHOCP with isolated network interfaces](https://docs.redhat.com/en/documentation/red_hat_openstack_services_on_openshift/18.0/html-single/deploying_red_hat_openstack_services_on_openshift/index#proc_preparing-RHOCP-with-isolated-network-interfaces_preparing_networks): for `NodeNetworkConfigurationPolicies` resources  
* [3.2.2. Attaching service pods to the isolated networks](https://docs.redhat.com/en/documentation/red_hat_openstack_services_on_openshift/18.0/html-single/deploying_red_hat_openstack_services_on_openshift/index#proc_attaching-service-pods-to-the-isolated-networks_preparing_networks): for `NetworkAttachmentDefinitions` resources  
* [3.2.3. Preparing RHOCP for RHOSO network VIPS](https://docs.redhat.com/en/documentation/red_hat_openstack_services_on_openshift/18.0/html-single/deploying_red_hat_openstack_services_on_openshift/index#proc_preparing-RHOCP-for-RHOSO-network-VIPs_preparing_networks) for `L2Advertisements` and `IPAdrressPool` resources  
* [3.3. CREATING THE DATA PLANE NETWORK](https://docs.redhat.com/en/documentation/red_hat_openstack_services_on_openshift/18.0/html-single/deploying_red_hat_openstack_services_on_openshift/index#proc_creating-the-data-plane-network_preparing_networks): for `NetConfig` resources

### openstack-controlplane

#### Purpose

Deploys and configures `OpenStackControlPlane` resource. Covers [Installation Documentation Chapter 4](https://docs.redhat.com/en/documentation/red_hat_openstack_services_on_openshift/18.0/html/deploying_red_hat_openstack_services_on_openshift/assembly_creating-the-control-plane)

#### Key resources

* `OpenStackControlPlane`

### openstack-dataplane

#### Purpose

Deploys and configures the OpenStack data plane nodes. Covers [Installation Documentation Chapter 5](https://docs.redhat.com/en/documentation/red_hat_openstack_services_on_openshift/18.0/html/deploying_red_hat_openstack_services_on_openshift/assembly_creating-the-data-plane)

#### Key resources

* `OpenStackDataPlaneNodeSet`  
* `OpenStackDataPlaneDeployment`

## What’s NOT covered by ArgoCD applications yet

### Dependencies installation

Dependencies such as `MetalLB`, `NMState` and `Cert-Manager` are not deployed nor managed using ArgoCD Application yet.

### Secret management and creation

Secrets are to be stored within a secure service, such as HashiCorp Vault, and never in Git. Our main focus for now is on the RHOSO application slicing, we will provide an ArgoCD Application definition later.

## Consume proposed components

### Base controlplane

Provides the base for IPAddressPool, L2Advertisement, NetworkAttachementDefinition,
NetConfig NodeNetworkConfigurationPolicy and OpenStackControlPlane on a 3-master OCP cluster.

The CR are extracted from the
[RHOSO official documentation](https://docs.redhat.com/en/documentation/red_hat_openstack_services_on_openshift/18.0/html/deploying_red_hat_openstack_services_on_openshift/assembly_creating-the-control-plane)

### Base dataplane

Provides the base for the OpenStackDataplaneNodeSet and OpenStackDataPlaneDeployment.

The CRs are extracted from the
[RHOSO official documentation](https://docs.redhat.com/en/documentation/red_hat_openstack_services_on_openshift/18.0/html/deploying_red_hat_openstack_services_on_openshift/assembly_creating-the-data-plane)

### ArgoCD sync-wave annotation
These annotations enable ArgoCD to determine the order that resources are created for the whole RHOSO cloud.
[Learn more about sync-waves](https://argo-cd.readthedocs.io/en/stable/user-guide/sync-waves/)

**Example usage**
1. Directly within the Application definition:
    ```yaml
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
    # [...]
    spec:
      project: "default"
      source:
        repoURL: "..."
        targetRevision: "..."
        path: "..."
        kustomize:
          components:
            -  https://github.com/openstack-k8s-operators/gitops/components/argocd/annotations?ref=TAG
    ```
1. From within an overlay or base:
    ```yaml
    apiVersion: kustomize.config.k8s.io/v1beta1
    kind: Kustomization
    components:
      - https://github.com/openstack-k8s-operators/gitops/components/argocd/annotations?ref=TAG
    # [...]
    ```

## External resources

1. [Official RHOSO documentation](https://docs.redhat.com/en/documentation/red_hat_openstack_services_on_openshift/18.0)
1. [Official openshift-gitops documentation](https://www.redhat.com/en/technologies/cloud-computing/openshift/gitops)
1. [Official ArgoCD documentation](https://argo-cd.readthedocs.io/en/stable/)
