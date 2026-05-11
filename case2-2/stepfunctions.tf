resource "aws_sfn_state_machine" "notify" {
    name     = "case2-2-notify-slack"
    role_arn = aws_iam_role.sfn_exec.arn

    definition = jsonencode({
        Comment = "Notify Slack via ECS"
        StartAt = "NotifySlack"
        States = {
            NotifySlack = {
                Type     = "Task"
                Resource = "arn:aws:states:::ecs:runTask.sync"
                Parameters = {
                    LaunchType     = "FARGATE"
                    Cluster        = aws_ecs_cluster.main.arn
                    TaskDefinition = aws_ecs_task_definition.notify_slack.arn
                    NetworkConfiguration = {
                        AwsvpcConfiguration = {
                            Subnets        = data.aws_subnets.default.ids
                            AssignPublicIp = "ENABLED"
                        }
                    }
                    Overrides = {
                        ContainerOverrides = [{
                            Name = "notify-slack"
                            Environment = [{
                                Name      = "MESSAGE"
                                "Value.$" = "$.message"
                            }]
                        }]
                    }
                }
                End = true
            }
        }
    })
}
