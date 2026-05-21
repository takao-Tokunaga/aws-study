resource "aws_scheduler_schedule" "notify" {
    name       = "case3-2-notify-slack"
    group_name = "default"

    flexible_time_window {
        mode = "OFF"
    }

    # cron is UTC. cron(0 0 * * ? *) = 09:00 JST every day
    schedule_expression          = var.schedule_expression
    schedule_expression_timezone = "Asia/Tokyo"

    target {
        arn      = aws_sfn_state_machine.notify.arn
        role_arn = aws_iam_role.scheduler_exec.arn

        input = jsonencode({
            message = var.slack_message
        })
    }
}
