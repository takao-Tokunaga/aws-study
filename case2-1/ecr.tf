resource "aws_ecr_repository" "api" {
    name                 = "takao-case2-1-api"
    image_tag_mutability = "MUTABLE"
    force_delete         = true

    image_scanning_configuration {
        scan_on_push = true
    }

    tags = {
        Name = "takao-case2-1-ecr"
    }
}
