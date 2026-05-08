resource "aws_ecr_repository" "wordpress" {
    name                 = "takao-case3-wordpress"
    image_tag_mutability = "MUTABLE"
    force_delete         = true

    image_scanning_configuration {
        scan_on_push = true
    }

    tags = {
        Name = "takao-case3-ecr"
    }
}
