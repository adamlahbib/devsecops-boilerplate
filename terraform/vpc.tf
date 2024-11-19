module "vpc" {
    source = "terraform-aws-modules/vpc/aws"

    name            = var.VPC_NAME
    cidr            = var.VpcCIDR
    azs             = var.subnet_zones
    private_subnets = var.private_subnets
    public_subnets  = var.public_subnets

    enable_nat_gateway = true
    single_nat_gateway = true

    enable_dns_hostnames = true
    enable_dns_support   = true

    vpc_tags = {
        Name = var.VPC_NAME
    }
}