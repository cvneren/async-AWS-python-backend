variable "region" {
  type        = string
  description = "AWS region for deployment."
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Environment name."

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "The environment must be one of: development, staging, production."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "The vpc_cidr must be a valid IPv4 CIDR block format."
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs."
}

variable "isolated_subnet_cidrs" {
  type        = list(string)
  description = "Isolated subnet CIDRs."
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones."
}

variable "container_image" {
  type        = string
  description = "Docker image for the worker."
}

variable "worker_cpu" {
  type        = number
  description = "CPU for worker."
  default     = 256
}

variable "worker_memory" {
  type        = number
  description = "Memory for worker."
  default     = 512
}
