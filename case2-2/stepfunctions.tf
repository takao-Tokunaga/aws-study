resource "aws_sfn_state_machine" "notify" {
    name     = "case2-2-notify-slack"
    role_arn = aws_iam_role.sfn_exec.arn

    definition = jsonencode({
        Comment = "Notify Slack via Lambda"
        StartAt = "NotifySlack"
        States = {
            NotifySlack = {
                Type     = "Task"
                Resource = aws_lambda_function.notify_slack.arn
                Parameters = {
                    "message.$" = "$.message"
                }
                End = true
            }
        }
    })
}
