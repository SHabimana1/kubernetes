# Output the created username
output "username" {
  description = "The name of the created IAM user"
  value       = aws_iam_user.eks_user.name
}

# Output the user's ARN (Amazon Resource Name)
output "user_arn" {
  description = "ARN of the created IAM user"
  value       = aws_iam_user.eks_user.arn
}

# Output location of credentials file (marked sensitive to hide in logs)
output "credentials_file" {
  description = "Path to the generated credentials file"
  value       = local_file.user_credentials.filename
  sensitive   = true # Prevents content from being shown in console
}