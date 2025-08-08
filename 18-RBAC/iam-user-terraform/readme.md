## Create IAM user with EKS Access using Terraform 
This folder contains the terraform code to automate the creation of the IAM user that will be used to setup RBAC

## Features:
- Creates an IAM user with programmatic access.
- Creates an IAM group (if it does not exist) and assigns the user to it.
- Attaches a policy with EKS read-only permissions (eks:DescribeCluster) to the user.
- Generates a credentials file for the user.
- Ensures existing users or groups are not duplicated.

## Prerequisites:
1. AWS CLI: Install and configure the AWS CLI with appropriate credentials.
2. Terraform: Install Terraform (v1.5.6 or later).

## Project Structure:

```
iam-user-terraform/
├── main.tf # Terraform configuration for AWS resources
├── variables.tf # Terraform variable definitions
├── outputs.tf  # Terraform outputs
├── policy.json # JSON policy for EKS access
├── credentials.tpl # Template for generating credentials
└── run.sh # bsh script for the run
```
**Note:** The ``terraform.tfvars`` file will be auto-generated using the values provided by the user during the script ``run.sh`` execution

## Usage:
1. Clone the Repository:
```bash
git clone <repository-url>
cd <repository-folder>/<code-folder>
```

2. Run the Script:
   Execute the `run.sh` script to start the process:
```bash
./run.sh 
or 
bash run.sh
```

3. Provide Inputs:
   - AWS region (default: us-east-1)
   - IAM username
   - Group name
   - Policy name (default: EKS_ACCESS_POLICY)

4. View Outputs:
   
After successful execution, the script will:
   - Display the generated credentials file path.
   - Output the IAM username and ARN.

5. Secure Credentials:
   - Store the credentials file securely.
   - Do not commit it to version control.

## Example:

```bash

$ ./run.sh


AWS IAM User Creator for EKS Access
-----------------------------------

Enter the AWS region [us-east-1]: us-east-2
Enter the IAM username (required): eks-user
Enter the IAM group name (required): eks-group
Policy name [EKS_ACCESS_POLICY]: 

Checking if user 'eks-user' exists in group 'eks-group'...
Group doesn't exist - it will be created.

Initializing Terraform...
...

Applying Terraform configuration...
...

=== Creation Complete ===
Credentials saved to: eks-user_credentials.txt
Username: eks-user
User ARN: arn:aws:iam::123456789012:user/eks-user

Important: Please secure these credentials immediately!
```


## Outputs:
- IAM Username: The name of the created IAM user.
- IAM User ARN: The Amazon Resource Name of the user.
- Credentials File: A file containing the user's access keys.

## Security Notes:
- Do not share credentials: Treat the credentials like passwords.
- Rotate keys regularly: Update access keys every 90 days.
- Restrict permissions: Ensure the policy grants only necessary access.

## Cleanup:
To remove all created resources, run:

```bash
terraform destroy -auto-approve
```