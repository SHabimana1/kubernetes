# AWS region where resources will be created
variable "aws_region" {
  description = "AWS region for resource creation"
  type        = string
  default     = "us-east-1"  # Default to N.Virginia
}

# Name for the IAM user to create
variable "iam_username" {
  description = "Name for the new IAM user"
  type        = string  
}

# Name for the IAM group
variable "iam_groupname" {
  description = "Name for the IAM group"
  type        = string
}

# Name for the created policy
variable "policy_name" {
  description = "Name for the IAM policy"
  type        = string
  default     = "EKS_ACCESS_POLICY"
}