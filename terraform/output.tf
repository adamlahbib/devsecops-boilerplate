output "region" {
    value = aws_eks_cluster.eks_cluster.region
}

output "cluster_name" {
    value = aws_eks_cluster.eks_cluster.name
}

output "repository_name" {
    value = aws_ecr_repository.ecr_repo.name
}

output "cluster_ip" {
    value = aws_eks_cluster.eks_cluster.endpoint
}