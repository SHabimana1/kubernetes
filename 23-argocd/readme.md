# Quick Lesson on ArgoCD

## What is ArgoCD?

**ArgoCD** (Argo Continuous Delivery) is a declarative, GitOps tool for Kubernetes that:
- Automates application deployments
- Synchronizes your actual application state with the desired state defined in Git
- Provides a web UI and CLI for monitoring and managing applications
- Simplifies rollbacks to previous versions when necessary 

## Core Concepts

### 1. GitOps Principle
- Your Git repository is the **single source of truth**
- Infrastructure and application definitions are stored as code in Git
- ArgoCD continuously monitors and reconciles differences. Any change in the repo automatically triggers a deployment to kubernetes

### 2. Key Components and concepts
- **Application**: The main custom resource that defines what to deploy
- **Source**: Git repository + path containing manifests
- **Destination**: Target cluster and namespace
- **Desired State/ target state**: The Kubernetes manifests (YAML/Helm/Kustomize) in Git.
- **Live State**: The actual state running inside the cluster.
- **Sync**: Argo CD makes sure live state = desired state. If they drift, Argo CD can auto-sync or let you manually sync.

## Argo CD Workflow

- Developer commits changes to Git repo (e.g., update a Deployment).
- Argo CD detects changes in the repo.
- Sync: Argo CD applies manifests to Kubernetes.
- Cluster is updated automatically → no kubectl apply -f needed.

## Basic Setup

### Installation
```bash
# Install ArgoCD in your cluster
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Get Admin Password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## Creating Your First Application

### 1. Via CLI
```bash
argocd app create my-app \
  --repo https://github.com/your-repo/app-manifests.git \
  --path manifests \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default
```

### 2. Via YAML Manifest
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-repo/app-manifests.git
    targetRevision: HEAD
    path: manifests
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      selfHeal: true
      prune: true
```

## Common Operations

### Sync Applications
```bash
# Manual sync
argocd app sync my-app

# Get application status
argocd app get my-app

# View application resources
argocd app resources my-app
```

### Rollback
```bash
# View history
argocd app history my-app

# Rollback to previous version
argocd app rollback my-app 2
```

## Best Practices

1. **Use ApplicationSets** for managing multiple applications
2. **Enable auto-sync** for development environments
3. **Use sync waves** for ordered resource creation
4. **Implement health checks** for proper status reporting
5. **Use projects** for multi-tenancy and access control

## Monitoring
- Web UI dashboard at port 8080 (forward with `kubectl port-forward`)
- CLI for quick checks and automation
- Integration with Prometheus for metrics

ArgoCD simplifies Kubernetes deployments by ensuring your cluster state always matches what's defined in your Git repository, providing audit trails, and enabling easy rollbacks.

# Practical Lab: Setup ArgoCD for a simple application in EKS cluster

### Prerequisites:
- Have **AWS CLI** and **eksctl** installed
- Have an AWS account with sufficient IAM permissions to create clusters, IAM roles, and EBS volumes
- Have **kubectl** installed and configured for Kubernetes operations

### Create your EKS cluster in AWS
To create the EKS cluster for this lab, use the following commands:


1. Set up a directory for cluster configuration:
mkdir eksctl-argo-project
```bash
cd eksctl-argo-project
```

2. Verify your AWS identity:
```bash
aws sts get-caller-identity
```

3. Create an EKS cluster:
```bash
eksctl create cluster --name my-cluster --region us-east-1 --nodegroup-name my-nodes --node-type t3.medium --nodes 2 --nodes-min 1 --nodes-max 2
```
4. Update the kubeconfig for the new cluster if necessary:
```bash
aws eks --region us-east-1 update-kubeconfig --name my-cluster
```
5- Verify Cluster Nodes:
```bash
kubectl get nodes
```

### Install and start Argo CD in a Kubernetes cluster


1. create a namespace for argo CD and install Argo CD in the created namespace
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
2. Verify the objects created
kubectl get pods,svc -n argocd

3. Change the argocd-server service type to LoadBalancer
```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```
List services and Copy the dns name of Loadbalancer from argocd-server service
```bash
kubectl get svc -n argocd
```
4. Get the password to connect to the admin account
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

5. Connect on the Argo UI with username: admin and the password generated by the below command

Note: you can change and delete init password


### Create an application in Argo-CD using a YAML file

1. Clone the git repository: `` git clone https://github.com/utrains/argocd-app-config.git ``
2. Create the application by applying the application.yaml file in argocd namespace: `` kubectl apply -f application.yaml -n argocd ``
3. Open the Argo CD UI to see all the resources. Navigate through them to see their specifications.

### Exercise:
Make the following actions on the deployment file to see how Argo CD update the deployment to match the repo state:
1. Change the deployment name
2. Change the container image to nginx:stable-alpine-perl
3. change the number of replicas to 4
4. Modify the service name

### Delete resources
After successfully done this lab, you must delete all the resources created to avoid charges:

1. Delete the Argo CD application:
```bash
kubectl delete -f application.yaml -n argocd
```

2. Delete all resources inside argocd namespace:
```bash
kubectl delete all --all -n argocd
```
3. Delete argocd and myapp namespaces:
```bash
kubectl delete namespace argocd
kubectl delete namespace myapp
```

4. Delete the EKS cluster:
```bash
eksctl delete cluster --name my-cluster --region us-east-1
```

### Links to Official Documentation of Argo CD:

* Install ArgoCD: [https://argo-cd.readthedocs.io/en/stable/getting_started/#1-install-argo-cd](https://argo-cd.readthedocs.io/en/stable/getting_started/#1-install-argo-cd)

* Login to ArgoCD: [https://argo-cd.readthedocs.io/en/stable/getting_started/#4-login-using-the-cli](https://argo-cd.readthedocs.io/en/stable/getting_started/#4-login-using-the-cli)

* ArgoCD Configuration: [https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/)