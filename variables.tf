variable "aws_region" {
  description = "AWS Region to deploy resources"
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name prefix for all resources"
  default     = "ecommerce"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  default     = "t3.micro"
}

variable "ami_owner" {
  description = "Owner ID for Ubuntu AMI (Canonical)"
  default     = "099720109477"
}
