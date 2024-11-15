module "ecr" {
    source = "terraform-aws-modules/ecr/aws"
    create_repository = true
    repository_name = var.repository_name
    repository_lifecycle_policy = jsonencode({
        rules = [
            {
                rulePriority = 1
                description = "Keep last 30 images"
                selection = {
                    tagStatus = "untagged"
                    countType = "imageCountMoreThan"
                    countNumber = 30
                },
                action = {
                    type = "expire"
                }
            }
        ]
    })
}