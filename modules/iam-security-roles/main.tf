# Data sources for account and region context
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Trust Relationship for ECS Tasks
data "aws_iam_policy_document" "ecs_tasks_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# --- ECS Task Execution Role ---
resource "aws_iam_role" "execution_role" {
  name               = "${local.role_name_prefix}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_trust.json
  description        = "Role assumed by the ECS agent to pull images and push logs."
}

data "aws_iam_policy_document" "execution_policy" {
  # ECR Authorization Token (Requires *)
  statement {
    sid       = "AllowECRAuth"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  # ECR Image Pull (Scoped)
  statement {
    sid = "AllowECRImagePull"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = var.ecr_repository_arns
  }

  # CloudWatch Logs Permissions (Scoped)
  statement {
    sid = "AllowCloudWatchLogs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    # Scoped to the specific log group prefix for the region/account
    resources = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/async-worker-${var.environment}:*"]
  }

  # Secrets Manager Permissions
  dynamic "statement" {
    for_each = length(var.secrets_manager_arns) > 0 ? [1] : []
    content {
      sid       = "AllowSecretsRetrieval"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = var.secrets_manager_arns
    }
  }
}

resource "aws_iam_role_policy" "execution_role_policy" {
  name   = "${local.role_name_prefix}-execution-policy"
  role   = aws_iam_role.execution_role.id
  policy = data.aws_iam_policy_document.execution_policy.json
}

# --- ECS Task Role ---
resource "aws_iam_role" "task_role" {
  name               = "${local.role_name_prefix}-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_trust.json
  description        = "Role assumed by the Python application to access AWS services."
}

data "aws_iam_policy_document" "task_policy" {
  # SQS Permissions
  statement {
    sid = "AllowSQSProcessing"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:GetQueueAttributes"
    ]
    resources = [var.sqs_queue_arn]
  }

  # S3 Permissions (Data Stores)
  dynamic "statement" {
    for_each = length(var.s3_bucket_arns) > 0 ? [1] : []
    content {
      sid = "AllowS3Access"
      actions = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ]
      resources = flatten([
        for arn in var.s3_bucket_arns : [arn, "${arn}/*"]
      ])
    }
  }
}

resource "aws_iam_role_policy" "task_role_policy" {
  name   = "${local.role_name_prefix}-task-policy"
  role   = aws_iam_role.task_role.id
  policy = data.aws_iam_policy_document.task_policy.json
}
