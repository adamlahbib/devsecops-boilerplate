resource "aws_ecr_repository" "ecr" {
    name                 = var.repository_name
    image_tag_mutability = "MUTABLE"

    lifecycle {
    prevent_destroy = true
    }
}

resource "aws_ecr_lifecycle_policy" "ecr_policy" {
    repository = aws_ecr_repository.ecr.name

    policy = jsonencode({
        rules = [
            {
            rulePriority = 1
            description  = "Keep last 30 images"
            selection = {
                tagStatus   = "untagged"
                countType   = "imageCountMoreThan"
                countNumber = 30
            }
            action = {
                type = "expire"
            }
            }
        ]
    })
}