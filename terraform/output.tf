output "region" {
    value = "eu-west-3"
}

output "cluster_name" {
    value = aws_eks_cluster.eks_cluster.name
}

output "repository_name" {
    value = aws_ecr_repository.ecr.repository_name
}

output "cluster_ip" {
    value = aws_eks_cluster.eks_cluster.endpoint
}