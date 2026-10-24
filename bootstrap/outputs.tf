output "state_bucket_name" {
  description = "Put this value in environments/*/backend.tf"
  value       = aws_s3_bucket.tf_state.bucket
}

output "github_actions_role_arn" {
  description = "Save this as the AWS_ROLE_ARN secret in GitHub"
  value       = aws_iam_role.github_actions.arn
}
