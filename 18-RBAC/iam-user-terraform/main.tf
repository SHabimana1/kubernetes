# Configure the AWS provider with region from variables
provider "aws" {
  region = var.aws_region
}

# Create an IAM group for EKS users
resource "aws_iam_group" "eks_users_group" {
  name = var.iam_groupname # Group name from variable

  lifecycle {
    # Prevents Terraform from trying to modify the group's policies
    # if they were changed outside of Terraform
    ignore_changes = [path]
  }
}

# Create the IAM user with specified username
resource "aws_iam_user" "eks_user" {
  name = var.iam_username # Username from variable
}

# Add the user to the created group
resource "aws_iam_user_group_membership" "eks_user_membership" {
  user   = aws_iam_user.eks_user.name 
  groups = [aws_iam_group.eks_users_group.name] 
}

# Create the IAM policy with EKS permissions
resource "aws_iam_policy" "eks_access_policy" {
  name        = var.policy_name 
  description = "Policy for basic EKS read-only access"
  policy      = file("${path.module}/policy.json") # Load policy from JSON file
}

# Attach the policy to the user
resource "aws_iam_user_policy_attachment" "eks_user_policy_attachment" {
  user       = aws_iam_user.eks_user.name
  policy_arn = aws_iam_policy.eks_access_policy.arn
}

# Create access keys for programmatic access
resource "aws_iam_access_key" "eks_user_keys" {
  user = aws_iam_user.eks_user.name
}

# Generate timestamp for credentials file
resource "time_static" "creation_time" {}

# Create the credentials file using template
resource "local_file" "user_credentials" {
  filename = "${var.iam_username}_credentials.txt" # Dynamic filename
  content = templatefile("${path.module}/credentials.tpl", {
    username          = aws_iam_user.eks_user.name
    user_arn          = aws_iam_user.eks_user.arn
    access_key_id     = aws_iam_access_key.eks_user_keys.id
    secret_access_key = aws_iam_access_key.eks_user_keys.secret
    region           = var.aws_region
    timestamp        = formatdate("YYYY-MM-DD hh:mm:ss Z", time_static.creation_time.rfc3339)
  })
  file_permission = "0600" # Restrictive permissions (only owner can read/write)
}