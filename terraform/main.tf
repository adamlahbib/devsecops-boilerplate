variable "GRAFANA_ADMIN_PASSWORD" { type= string } 

terraform {
    backend "s3" {}
}

data "aws_eks_cluster_auth" "cluster_auth" {
    name = var.cluster_name
}

resource "aws_eks_cluster" "eks_cluster" {
    name     = var.cluster_name
    role_arn = aws_iam_role.eks_role.arn

    vpc_config {
        subnet_ids = module.vpc.private_subnets
        security_group_ids = [aws_security_group.eks_cluster_sg.id]
    }

    depends_on = [aws_iam_role_policy_attachment.eks_policy_attachment]
}

resource "aws_iam_role" "eks_role" {
    name = "eks-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Principal = {
                    Service = "eks.amazonaws.com"
                },
                Action = "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "eks_policy_attachment" {
    role       = aws_iam_role.eks_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_ami" "node-image" {
    owners      = ["amazon"]
    most_recent = true

    filter {
    name   = "name"
    values = ["amazon-eks-node-1.31-*"]
    }

    filter {
    name   = "virtualization-type"
    values = ["hvm"]
    }

    filter {
    name   = "root-device-type"
    values = ["ebs"]
    }
}

resource "aws_iam_instance_profile" "eks_instance_profile" {
    name = "eks-instance-profile"
    role = aws_iam_role.eks_role.name
}

resource "aws_iam_instance_profile" "eks_node_instance_profile" {
    name = "eks-node-instance-profile"
    role = aws_iam_role.worker_role.name
}

resource "aws_launch_template" "eks_launch_template" {
    block_device_mappings {
        device_name = "/dev/xvda"
        ebs {
            delete_on_termination = true
            volume_size           = 20
            volume_type           = "gp2"
        }
    }

    name_prefix   = "eks-node"
    image_id        = data.aws_ami.node-image.id
    user_data = base64encode(<<-SCRIPT
        #!/bin/bash
        set -o xtrace
        /etc/eks/bootstrap.sh ${var.cluster_name} \
            --use-max-pods false \
            --kubelet-extra-args '--max-pods=150'
        SCRIPT
    )

    metadata_options {
        http_endpoint = "enabled"
        http_tokens   = "optional"
    }
}

resource "aws_eks_node_group" "eks_nodes" {
    cluster_name    = aws_eks_cluster.eks_cluster.name
    node_group_name = "eks-node-group"
    node_role_arn   = aws_iam_role.worker_role.arn
    subnet_ids      = [module.vpc.private_subnets]
    ami_type        = "AL2024_x86_64_STANDARD"
    instance_types  = ["t3.micro"]
    disk_size       = 20
    capacity_type   = "ON_DEMAND"

    launch_template {
        id = aws_launch_template.eks_launch_template.id
        version = "$Latest"
    }

    scaling_config {
        desired_size = 2
        max_size     = 3
        min_size     = 1
    }

    update_config {
        max_unavailable = 1
    }

    depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_iam_role" "worker_role" {
    name = "eks-worker-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Principal = {
                    Service = "ec2.amazonaws.com"
                },
                Action = "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "worker_node_attach_AmazonEKSWorkerNodePolicy" {
    role       = aws_iam_role.worker_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "worker_node_attach_AmazonEKS_CNI_Policy" {
    role       = aws_iam_role.worker_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "worker_node_attach_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker_role.name
}