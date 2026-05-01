variable "environment" {
  type        = string
  description = "Deployment environment name (e.g., development, staging, production)."

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "The environment must be one of: development, staging, production."
  }
}

variable "sqs_queue_arn" {
  type        = string
  description = "The ARN of the SQS queue the asynchronous worker will process."
}

variable "secrets_manager_arns" {
  type        = list(string)
  description = "List of Secrets Manager ARNs the execution role needs access to."
  default     = []
}

variable "s3_bucket_arns" {
  type        = list(string)
  description = "List of S3 bucket ARNs the task role needs access to."
  default     = []
}

variable "ecr_repository_arns" {
  type        = list(string)
  description = "List of ECR repository ARNs for image pulling."
}
