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
        cloudflare = {
            source  = "cloudflare/cloudflare"
            version = "~> 3.0"
        }
    }
}

provider "aws" {
    region = var.aws_region
}

provider "helm" {
    kubernetes {
        host = aws_eks_cluster.eks_cluster.endpoint
        token = data.aws_eks_cluster_auth.cluster_auth.token
        insecure = true
    }
}

provider "kubernetes" {
    host = aws_eks_cluster.eks_cluster.endpoint
    token = data.aws_eks_cluster_auth.cluster_auth.token
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority.0.data)
}

provider "cloudflare" {
    api_token = var.CLOUDFLARE_TOKEN
}