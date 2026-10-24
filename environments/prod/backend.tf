# Replace the bucket with the value from: cd bootstrap && terraform output state_bucket_name
terraform {
  backend "s3" {
    bucket       = "mycompany-terraform-state-12345"
    key          = "prod/terraform.tfstate"
    region       = "eu-south-1"
    encrypt      = true
    use_lockfile = true # native S3 locking, no DynamoDB table needed
  }
}
