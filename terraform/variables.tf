variable "GRAFANA_ADMIN_PASSWORD" { type= string } 
variable "CLOUDFLARE_ZONE_ID" { type= string }
variable "CLOUDFLARE_TOKEN" { type= string }
variable "CLOUDFLARE_EMAIL" { type= string }
variable "CLOUDFLARE_API_TOKEN" { type= string }
variable "SLACK_WEBHOOK" { type= string }
variable "TAILSCALE_CLIENT_ID" { type= string }
variable "TAILSCALE_CLIENT_SECRET" { type= string }
variable "CROWDSEC_ENROLL_KEY" { type= string }

variable "project_name" {
    description = "Name of the project"
    type        = string
    default     = "aqemia"
}

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

variable "aws_zone" {
    description = "Availability zone name"
    type        = string
    default    = "eu-west-3a"
}

variable "dns_name" {
    description = "DNS name"
    type        = string
}

variable "slack_channel" {
    description = "Slack channel"
    type        = string
}

variable "slack_username" {
    description = "Slack username"
    type        = string
}

variable "slack_icon" {
    description = "Slack icon"
    type        = string
}

variable "tailnet" {
    description = "Tailnet"
    type        = string
}