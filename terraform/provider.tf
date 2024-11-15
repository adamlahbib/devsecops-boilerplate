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
            kubernetes {
                host = aws_eks_cluster.eks_cluster.endpoint
                token = aws_eks_cluster_auth.cluster_auth.token
                insecure = true
            }
        }
    }
}

provider "aws" {
    region = var.aws_region
}