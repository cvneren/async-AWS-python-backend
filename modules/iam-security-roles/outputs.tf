output "execution_role_arn" {
  value       = aws_iam_role.execution_role.arn
  description = "The ARN of the ECS Task Execution Role."
}

output "task_role_arn" {
  value       = aws_iam_role.task_role.arn
  description = "The ARN of the ECS Task Role."
}
