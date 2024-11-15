output "region" {
    value = var.aws_region
}

output "cluster_name" {
    value = var.cluster_name
}

output "repository_name" {
    value = var.repository_name
}

output "cluster_ip" {
    value = aws_eks_cluster.eks_cluster.endpoint
}