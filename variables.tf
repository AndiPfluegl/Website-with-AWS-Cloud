# Defines the AWS region where resources will be created.
# It's set to 'eu-central-1' by default but can be overridden:
variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-central-1"
}

# Specifies the Amazon Machine Image (AMI) ID used for launching EC2 instances.
# The default value is set to a specific AMI ID, but it can be changed as needed:
variable "ami_id" {
  description = "AMI ID for launching EC2 instances"
  type        = string
  default     = "ami-03484a09b43a06725"
}

# Determines the type of EC2 instance to launch.
# By default, it uses 't2.micro', suitable for small-scale and cost-effective applications:
variable "instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
  default     = "t2.micro"
}

# Contains a list of subnet IDs within your Virtual Private Cloud (VPC) where resources will be deployed.
# This supports deploying resources across multiple subnets for high availability:
variable "vpc_subnets" {
  description = "List of subnet IDs for the VPC"
  type        = list(string)
  default     = ["subnet-087dec22598c86267", "subnet-0877e3d0e36d50357", "subnet-01ae5fd544fd58359"]
}

# Sets a target for CPU utilization percentage that triggers autoscaling actions.
# When the CPU utilization hits 50% (default value), it will initiate scaling to maintain performance:
variable "target_cpu_utilization" {
  description = "Target CPU utilization percentage for autoscaling"
  type        = number
  default     = 50
}