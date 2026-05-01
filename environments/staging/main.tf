provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "async-python-backend"
      ManagedBy   = "Terraform"
      Owner       = "platform-team"
    }
  }
}

# --- Core Networking ---
module "networking" {
  source = "../../modules/networking-core"

  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  isolated_subnet_cidrs = var.isolated_subnet_cidrs
  availability_zones    = var.availability_zones
}

# --- Message Broker (SQS) ---
resource "aws_sqs_queue" "async_tasks" {
  name                      = "async-tasks-${var.environment}"
  message_retention_seconds = 86400
  receive_wait_time_seconds = 20 # Long polling

  tags = {
    Name = "async-tasks-${var.environment}"
  }
}

# --- Container Registry (ECR) ---
resource "aws_ecr_repository" "worker" {
  name                 = "async-worker-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# --- IAM Security Roles ---
module "iam" {
  source = "../../modules/iam-security-roles"

  environment         = var.environment
  sqs_queue_arn       = aws_sqs_queue.async_tasks.arn
  ecr_repository_arns = [aws_ecr_repository.worker.arn]
}

# --- Compute Orchestration (ECS) ---
module "ecs_worker" {
  source = "../../modules/ecs-async-worker"

  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  execution_role_arn = module.iam.execution_role_arn
  task_role_arn      = module.iam.task_role_arn
  container_image    = var.container_image
  container_cpu      = var.worker_cpu
  container_memory   = var.worker_memory
  sqs_queue_name     = aws_sqs_queue.async_tasks.name
  sqs_queue_arn      = aws_sqs_queue.async_tasks.arn
}
