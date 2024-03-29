# Website-with-AWS-Cloud
Host a simple Website in AWS Cloud with Terraform

## Project Description
This Terraform project sets up a simple static homepage using AWS Cloud Services, including EC2 instances for web hosting, an autoscaling group for handling load dynamically, an Application Load Balancer (ALB) for distributing incoming traffic, and a CloudFront distribution for global content delivery. The infrastructure is designed for scalability, security, and high availability.

## Prerequisites
Before starting, ensure you have the following prerequisites ready:

1. Terraform installed on your machine.
2. An AWS account with permissions to create the defined resources.
3. AWS CLI configured with user credentials.
4. Configuration
   
The project includes a variables.tf file, which defines several key parameters for the AWS resources. You can customize these values according to your needs:
* region: The AWS region where resources will be deployed. Default is eu-central-1.
* ami_id: The Amazon Machine Image (AMI) ID for EC2 instances. Default is set to a specific AMI in eu-central-1.
* instance_type: The type of EC2 instance. Default is t2.micro.
* vpc_subnets: A list of subnet IDs in your VPC for resource deployment, supporting high availability.
* target_cpu_utilization: The CPU utilization percentage that triggers autoscaling actions. Default is 50%.

## Usage
* Initialize Terraform: terraform init
* Review the Plan: terraform plan
* Deploy the Infrastructure: terraform apply
* To destroy the deployed infrastructure (when needed): terraform destroy

## Additional Information
* Security Group Configuration: The project sets up a security group to allow HTTP and HTTPS traffic.
* Autoscaling: An autoscaling group adjusts the number of EC2 instances based on CPU utilization.
* Load Balancing: An ALB distributes incoming traffic to ensure high availability.
* Content Delivery: CloudFront delivers the web content globally for improved load times.

## Contributing Contributions to improve the project are welcome. Fork the repository, make your changes, and submit a pull request.

