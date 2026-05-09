resource "aws_efs_file_system" "wordpress" {
    creation_token = "takao-case3-efs"
    encrypted      = true

    tags = {
        Name = "takao-case3-efs"
    }
}

resource "aws_efs_mount_target" "private_1a" {
    file_system_id  = aws_efs_file_system.wordpress.id
    subnet_id       = aws_subnet.private_1a.id
    security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_mount_target" "private_1c" {
    file_system_id  = aws_efs_file_system.wordpress.id
    subnet_id       = aws_subnet.private_1c.id
    security_groups = [aws_security_group.efs_sg.id]
}
