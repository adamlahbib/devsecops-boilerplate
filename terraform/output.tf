output "region" {
    value = "eu-west-3"
}

output "cluster_name" {
    value = aws_eks_cluster.eks_cluster.name
}

output "repository_name" {
    value = module.ecr.repository_name
}

output "cluster_ip" {
    value = aws_eks_cluster.eks_cluster.endpoint
}