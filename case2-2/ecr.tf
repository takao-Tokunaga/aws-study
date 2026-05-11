resource "aws_ecr_repository" "notify_slack" {
    name                 = "case2-2-notify-slack"
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
        scan_on_push = true
    }
}
