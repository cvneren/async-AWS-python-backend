[![CI](https://github.com/cvneren/async-AWS-python-backend/actions/workflows/ci.yml/badge.svg)](https://github.com/cvneren/async-AWS-python-backend/actions/workflows/ci.yml)
![Terraform](https://img.shields.io/badge/Terraform-%3E%3D_1.10.0-623CE4?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-Event--Driven-FF9900?logo=amazon-aws)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

# Asynchronous Python Backend Infrastructure on AWS

## 1. Business Value and Problem Statement
Modern enterprise Python workloads involving resource-intensive operations—such as machine learning inferences, complex data manipulation, or external API communications—often exceed the strict execution limits of synchronous request-response cycles. Relying on synchronous architectures introduces catastrophic risks, including exhausted thread pools, socket timeouts, and integration limits (e.g., the Amazon API Gateway 29-second timeout).

This project provides a production-ready, Infrastructure-as-Code (IaC) solution that decouples request ingestion from asynchronous computational processing. By utilizing an event-driven architecture, the system absorbs unpredictable traffic spikes through a message broker, ensuring high availability, deterministic compute performance, and absolute execution reliability for long-running tasks.

## 2. Architectural Decisions

### 2.1 Compute Orchestration: AWS ECS Fargate
Amazon ECS on AWS Fargate was selected as the optimal compute layer. This decision bypasses the 15-minute execution limits and unpredictable cold-start latencies of AWS Lambda, while avoiding the excessive operational complexity and control-plane costs associated with Amazon EKS. The architecture utilizes Fargate Spot capacity providers to reduce compute costs by up to 70% for fault-tolerant asynchronous processing.

### 2.2 Secure State Management: Native S3 Locking
This implementation deprecates the legacy DynamoDB-based state locking pattern. By leveraging Terraform 1.10.0+ native S3 optimistic locking (`use_lockfile = true`), the architecture collapses the infrastructure dependency tree, reduces the IAM attack surface, and eliminates the operational overhead of managing auxiliary NoSQL tables for foundational bootstrapping.

### 2.3 Network Economics and Isolation
The Virtual Private Cloud (VPC) is designed with a three-tier topology (Public, Private, Isolated). To mitigate the extreme data processing charges associated with Managed NAT Gateways during container image pulls, the architecture implements:
- **Interface Endpoints**: Dedicated PrivateLink connections for ECR, SQS, CloudWatch Logs, and Secrets Manager.
- **Gateway Endpoints**: Direct, free network-layer routing for Amazon S3.

### 2.4 Identity and Access Management (IAM)
Adhering to the principle of least privilege, the system enforces:
- **Separation of Duties**: Distinct ECS Task Execution Roles (infrastructure plane) and ECS Task Roles (application plane).
- **Resource-Bound Policies**: Elimination of wildcard permissions (`*`) in favor of granular, ARN-scoped policies constructed via `aws_iam_policy_document`.

## 3. Local Execution and Development

### 3.1 Prerequisites
- **Terraform**: version `>= 1.10.0` (required for native S3 locking).
- **TFLint**: Required for static analysis and AWS ruleset validation.
- **AWS CLI**: Configured with appropriate credentials for target environment access.

### 3.2 Directory Structure
The repository follows a strict modular layout:
- `modules/`: Reusable, flat infrastructure components (Networking, IAM, ECS).
- `environments/`: Logically isolated root modules for `development`, `staging`, and `production`.

### 3.3 Deployment Workflow
1. **Initialize the Environment**:
   Navigate to the target environment directory and initialize the backend.
   ```bash
   cd environments/development
   terraform init
   ```

2. **Validate Code Quality**:
   Run TFLint from the repository root to ensure compliance with architectural standards.
   ```bash
   tflint --recursive
   ```

3. **Plan and Apply**:
   Generate an execution plan and apply the infrastructure changes.
   ```bash
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

## 4. Universal Resource Tagging
All resources are automatically tagged via the `aws_default_tags` provider block, ensuring consistent metadata propagation for cost center allocation, project ownership, and environment isolation.
