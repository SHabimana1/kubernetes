# Setting Up RBAC for a New User in Amazon EKS using serviceaccount 

**Important Note**: This lab should be done in the EKS cluster launched with eksctl.

## **Overview**

We have a new user called Paul in dev team and we need to give him access to the cluster resources. As an administrator, setup RBAC using a serviceaccount to allow Adam to list, create and delete pods and services in the dev namespace. 

Steps:
- Create IAM user for Paul with policy for EKS access and access credentials to configure AWS CLI,
- Create Role, Rolebinding, Service account, Secret(to set up the token for the service account),
- Create the Kubeconfig file for Paul,
- Verify the permissions.
- 

---

## **Step 1: Create an IAM User and Get Their ARN**

Here, we must create a user call **paul** in the group **dev-group** then attach the **eks:DescribeCluster** policy to the user to allow authentication to EKS.

At the end we must keep the user **ARN**. We will use a bash script to create a user in a group and attach the defined policy.

**Note:** The script depends on the `jq` package that needs to be installed on your computer.
Run the following command to install it:

- **On Windows**
Open Powershell as Administrator and use choco to install the package
```bash
choco install jq
```

- **On Mac**
Use Homebrew to install the package
```bash
brew install jq
```

- **On Ubuntu**
Use apt to install the jq package
```bash
sudo apt update
sudo apt install jq
```
After successful installation of `jq` you can run the `create-eks-user.sh` script (find the script in this same folder). 

After complete execution, the script will generate a credential file containing the user name, the user ARN, the access keys and secret key for the user to configure AWS CLI and access the cluster. 

```bash
code paul_credentials.txt
# we created a user called Adam in the group dev-group
```
---

## **Step 2: Create Role, Rolebinding, Service account, Secret(to set up the token for the service account),**

1. First create the namespace dev in your cluster if it does not yet exist: 
```bash
kubectl create ns dev
```

2. Create the role and the rolebinding, serviceaccount and secret for the user. Create a manifest file and paste the content of `rbac-sa.yaml`

3. Apply the manifest to the cluster:
```bash
kubectl apply -f rbac-sa.yaml
```
---

## **Step 3: Create the Kubeconfig file for Paul**
The file `config-template.yaml`in this folder represent the template used to generate the Kubeconfig file for Paul.
To fill in this template, we need crucial information:
- The cluster name
- The API Server URL
- The cluster certificate data
- The service account token and more

Create a kubeconfig file for Paul from the template. Create a file called `paul-kubeconfig.yaml`, copy the content of the `config-template.yaml` file and paste in it.
Now, we need to replace the placeholders with the correct values.

### Get API server URL

Use the following command:
```bash
aws eks describe-cluster --name <your-cluster-name> --region <your-region> --query "cluster.endpoint" --output text
```
Example:
```bash
aws eks describe-cluster --name my-cluster --region us-east-1 --query "cluster.endpoint" --output text
```
Copy the value you get and replace the corresponding placeholder in the config template file

### Get cluster CA certificate
Use the command:
```bash
aws eks describe-cluster --name <your-cluster-name> --query "cluster.certificateAuthority.data" --output text
```
Example:
```bash
aws eks describe-cluster --name my-cluster --region us-east-1 --query "cluster.certificateAuthority.data" --output text
```
Copy the value you get and replace the corresponding placeholder in the config template file

### Get the token for Paul
Use the command:
```bash
kubectl get secret paul-token -n dev-team -o jsonpath='{.data.token}' | base64 --decode
```
Copy the value you get and replace the corresponding placeholder in the config template file

### Fill in the contexts section

The contexts section should look like the following for this example

```yaml
contexts:
- name: paul-context
  context:
    cluster: my-cluster
    user: paul
    namespace: dev
current-context: paul-context
```

The final config file (`paul-kubeconfig.yaml`) as well as the AWS CLI credentials (`paul-credentials.txt`) should be sent to Paul via a secure method depending on the company policies. (e.g., encrypted email, private Slack message)

## **Step 4: Verify the permissions**

**Notes:** Paul should have `kubectl` installed on his computer as a prerequisite.

Paul should save the files on his local environment. Configure AWS CLI with the credentials then set the `KUBECONFIG` environment variable to use the right config file
**Note:** You can move to the directory where you stored `paul-kubeconfig.yaml` file or simply specify the path to that file in the following command:

```bash
export KUBECONFIG=paul-kubeconfig.yaml
## or export KUBECONFIG=/path/to/the/config/file
```
Verify access
```sh
kubectl auth can-i create pods --namespace=dev
kubectl auth can-i list pods --namespace=dev
```

If set up correctly, the user should be able to **create and list pods** in the `dev` namespace but not perform any other actions.

---

## **Step 5: Verify access (Paul side)

On Paul's side, he must make sure AWS CLI is installed and configured with access keys and secret keys on his local computer. He must also install `kubectl` to be able to interact with kubernetes clusters.
1. Configure AWS CLI with IAM User Credentials (generated by the script we ran ealier)
Verify
```bash
aws --version
kubectl version --client
aws configure
# Enter the IAM user's Access Key ID and Secret Access Key.
# Set the default region to match the EKS cluster's region in this case us-east-1
aws sts get-caller-identity
# It should return IAM User ARN.
```
2. Update kubeconfig for Cluster Access
Paul should save the kubeconfig file on his local environment then set the `KUBECONFIG` environment variable to use the right config file
**Note:** You can move to the directory where you stored `paul-kubeconfig.yaml` file or simply specify the path to that file in the following command:

```bash
export KUBECONFIG=paul-kubeconfig.yaml
## or export KUBECONFIG=/path/to/the/config/file
```
verify access
```bash
kubectl get pods
kubectl get pods -n dev
kubectl auth can-i create pods --namespace=dev
kubectl auth can-i delete pods --namespace=dev
kubectl auth can-i create deployment --namespace=dev
kubectl auth can-i delete service --namespace=dev
```
It should return "yes" for the objects he can create or "no" for the ones he cannot create.

If Adam tries to create a deployment or list nodes he will get a Forbidden error.

# Clean Up

At the end of the practice, always delete resources created.
**Note: If you configured Paul IAM credentials in your terminal to practice this lab, remember to reconfigure aws cli with your normal IAM user account credentials to be able to continue managing your resources.**

To delete the resources created by the `create-eks-user.sh` script, you can use the `delete-eks-user.sh` script present in this same folder.
You can verify that the user was successfully delete with the command (if the username was Adam):

```bash
aws iam get-user --user-name paul
```