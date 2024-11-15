terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 5.46.0"
        }
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = ">= 2.0.2"
        }
        helm = {
            source  = "hashicorp/helm"
            version = ">= 2.0.2"
        }
    }
}

provider "aws" {
    region = var.aws_region
}