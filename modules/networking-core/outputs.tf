output "vpc_id" {
  value       = aws_vpc.this.id
  description = "The ID of the VPC."
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "List of IDs of public subnets."
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "List of IDs of private subnets."
}

output "isolated_subnet_ids" {
  value       = aws_subnet.isolated[*].id
  description = "List of IDs of isolated subnets."
}
