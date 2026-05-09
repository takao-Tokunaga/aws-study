resource "aws_db_subnet_group" "db" {
    name       = "takao-case2-1-db-subnet-group"
    subnet_ids = [aws_subnet.db_1a.id, aws_subnet.db_1c.id]

    tags = {
        Name = "takao-case2-1-db-subnet-group"
    }
}

resource "aws_db_instance" "main" {
    identifier        = "takao-case2-1-db"
    engine            = "mysql"
    engine_version    = "8.0"
    instance_class    = "db.t3.micro"
    allocated_storage = 20

    db_name  = "taskdb"
    username = "apiuser"
    password = var.db_password

    db_subnet_group_name   = aws_db_subnet_group.db.name
    vpc_security_group_ids = [aws_security_group.rds_sg.id]

    skip_final_snapshot     = true
    multi_az                = false
    storage_encrypted       = true
    backup_retention_period = 0

    tags = {
        Name = "takao-case2-1-rds"
    }
}
