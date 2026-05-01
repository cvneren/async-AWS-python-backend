variable "environment" {
  type        = string
  description = "Deployment environment name (e.g., development, staging, production)."

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "The environment must be one of: development, staging, production."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC."

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "The vpc_cidr must be a valid IPv4 CIDR block format."
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for the public subnets."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for the private subnets."
}

variable "isolated_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for the isolated subnets."
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to use for subnets."
}
