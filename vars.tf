variable "region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "The name of the S3 bucket to create."
  default = "ksabir_s3bucket"
  type        = string
}

variable "lambda_name" {
  description = "The name of the Lambda function to create."
  type        = string
}

variable "iam_role_name" {
  description = "The name of the IAM role to create for the Lambda function."
  type        = string
}

variable "email_address" {
  description = "The email address of the DevOps team to receive notifications."
  default = "khurrumsabir2@gmail.com"
  type        = string
}
