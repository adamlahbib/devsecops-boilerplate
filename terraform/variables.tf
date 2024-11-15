variable "aws_region" {
    description = "AWS Region to deploy resources"
    type        = string
    default     = "eu-west-3"
}

variable "cluster_name" {
    description = "Name of the EKS Cluster"
    type        = string
}

variable "VPC_NAME" {
    description = "VPC Name"
    type        = string
}

variable "VpcCIDR" {
    description = "VPC CIDR block"
    type        = string
    default     = "172.21.0.0/16"
}

variable "private_subnets" {
    description = "Private subnet CIDRs"
    type        = list(string)
    default     = ["172.21.4.0/24", "172.21.5.0/24", "172.21.6.0/24"]
}

variable "public_subnets" {
    description = "Public subnet CIDRs"
    type        = list(string)
    default     = ["172.21.1.0/24", "172.21.2.0/24", "172.21.3.0/24"]
}

variable "subnet_zones" {
    description = "Subnet zones"
    type        = list(string)
    default     = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
}

variable "repository_name" {
    description = "Name of the ECR repository"
    type        = string
}