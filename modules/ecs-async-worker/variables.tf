variable "environment" {
  type        = string
  description = "Deployment environment name (e.g., development, staging, production)."

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "The environment must be one of: development, staging, production."
  }
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for the ECS tasks."
}

variable "execution_role_arn" {
  type        = string
  description = "ARN of the ECS Task Execution Role."
}

variable "task_role_arn" {
  type        = string
  description = "ARN of the ECS Task Role."
}

variable "container_image" {
  type        = string
  description = "The Docker image for the asynchronous worker."
}

variable "container_cpu" {
  type        = number
  description = "CPU units for the task (e.g., 256, 512, 1024)."
  default     = 256
}

variable "container_memory" {
  type        = number
  description = "Memory for the task (e.g., 512, 1024, 2048)."
  default     = 512
}

variable "sqs_queue_name" {
  type        = string
  description = "The name of the SQS queue for auto scaling."
}

variable "sqs_queue_arn" {
  type        = string
  description = "The ARN of the SQS queue."
}

variable "min_capacity" {
  type        = number
  description = "Minimum number of tasks for auto scaling."
  default     = 1
}

variable "max_capacity" {
  type        = number
  description = "Maximum number of tasks for auto scaling."
  default     = 10
}
