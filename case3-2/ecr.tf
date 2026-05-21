resource "aws_ecr_repository" "notify_slack" {
    name                 = "case3-2-notify-slack"
    image_tag_mutability = "MUTABLE"
    force_delete         = true

    image_scanning_configuration {
        scan_on_push = true
    }
}
