#!/bin/bash
set -e # Exit immediately if any command fails

echo "AWS IAM User Creator for EKS Access"
echo "-----------------------------------"

# Read inputs
read -p "Enter the AWS region [us-east-1]: " aws_region
aws_region=${aws_region:-us-east-1}

read -p "Enter the IAM username (required): " iam_username
while [[ -z "$iam_username" ]]; do
  echo "Username cannot be empty!"
  read -p "Enter the IAM username (required): " iam_username
done

read -p "Enter the IAM group name (required): " iam_groupname
while [[ -z "$iam_groupname" ]]; do
  echo "Group name cannot be empty!"
  read -p "Enter the IAM group name (required): " iam_groupname
done

read -p "Policy name [EKS_ACCESS_POLICY]: " policy_name
policy_name=${policy_name:-EKS_ACCESS_POLICY}

# Configure AWS CLI profile if needed
# export AWS_PROFILE=your_profile

echo -e "\nChecking if user '$iam_username' exists in group '$iam_groupname'..."

# Check if group exists
if aws iam get-group --group-name "$iam_groupname" --region "$aws_region" >/dev/null 2>&1; then
  echo "Group '$iam_groupname' exists. Checking for user membership..."
  
  # Check if user exists in group
  if aws iam list-groups-for-user --user-name "$iam_username" --region "$aws_region" | grep -q "$iam_groupname"; then
    echo -e "\nERROR: User '$iam_username' already exists in group '$iam_groupname'!" >&2
    echo "Please choose either:" >&2
    echo "1. A different username" >&2
    echo "2. A different group name" >&2
    echo "3. Manually verify in AWS Console" >&2
    echo -e "\nAborting creation process." >&2
    exit 1
  else
    echo "User does not exist in group - proceeding with creation."
  fi
else
  echo "Group doesn't exist - it will be created."
fi

# Generate terraform.tfvars
cat > terraform.tfvars <<EOF
aws_region    = "$aws_region"
iam_username  = "$iam_username"
iam_groupname = "$iam_groupname"
policy_name   = "$policy_name"
EOF

echo -e "\nInitializing Terraform..."
terraform init

echo -e "\nApplying Terraform configuration..."
terraform apply -auto-approve

echo -e "\n=== Creation Complete ==="
echo "Credentials saved to: $(terraform output -raw credentials_file)"
echo "Username: $(terraform output -raw username)"
echo "User ARN: $(terraform output -raw user_arn)"
echo -e "\nImportant: Please secure these credentials immediately!"