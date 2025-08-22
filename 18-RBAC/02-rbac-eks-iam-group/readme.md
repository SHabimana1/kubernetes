# Setup RBAC for a IAM group of Users

## 1- Create the IAM role
### Create the Trust policy document
Create the file ``TrustPolicy.json`` with the following content. replace the `<ACCOUNT_ID>` with your own account ID
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::<ACCOUNT_ID>:root" },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### Create the policy that enable to access the eks cluster
Create a file `describe-cluster-policy.json` for the inline policy that will enable users to access the cluster. The content should look like the following:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:DescribeCluster"
      ],
      "Resource": "arn:aws:eks:us-east-1:<ACCOUNT_ID>:cluster/my-cluster"
    }
  ]
}
```
Now, create the policy in AWS:
```bash
aws iam create-policy   --policy-name EKSDescribeClusterPolicy   --policy-document file://describe-cluster-policy.json
```

### Create the role with the trust policy, then attach the `describe-cluster-policy.json` to the role.

```bash
aws iam create-role --role-name K8sDeveloperAccessRole --assume-role-policy-document file://TrustPolicy.json
```
Attach the policy
```bash
aws iam attach-role-policy \
  --role-name K8sDeveloperAccessRole \
  --policy-arn arn:aws:iam::<ACCOUNT_ID>:policy/EKSDescribeClusterPolicy
```

## 2- Create the IAM Group with policy
Create the group in AWS
```bash
aws iam create-group --group-name k8s-developers
```
Create the policy that will enable the users of the group to assume the role created earlier.

- Create the policy document `AllowAssumeRolePolicy.json` with the following content

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::<ACCOUNT_ID>:role/K8sDeveloperAccessRole"
    }
  ]
}
```
- Attach the policy to the group

```bash
aws iam put-group-policy --group-name k8s-developers --policy-name AllowAssumeK8sRolePolicy --policy-document file://AllowAssumeRolePolicy.json
```

## 3- Map the IAM role to the Kubernetes RBAC group

Here, we need to modify the `aws-auth` config map

```bash
kubectl get configmap aws-auth -n kube-system -o yaml > aws-auth.yaml
```
Edit aws-auth.yaml to add the role mapping under mapRoles:

```bash
- rolearn: arn:aws:iam::<ACCOUNT_ID>:role/K8sDeveloperAccessRole
  username: developer
  groups:
    - dev-team-group
```
Apply the updated ConfigMap:
```bash
kubectl apply -f aws-auth.yaml
```

## 4- Create namespace, role and role binding for rbac

Use the `rbac-setup.yaml` file and apply it to the cluster


## 5- Onboarding a new user

### Create an IAM user and attach to the group
### Configure AWS CLI for the new user (use temporary credentials for testing)
- Assume the role
-export the credentials via environment variables
- update the kubeconfig
- test by accessing a pod

## 6- Clean up