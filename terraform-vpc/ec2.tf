resource "aws_key_pair" "my_key" {
  key_name   = "my-key"
  public_key = file("my-key.pub")
}

resource "aws_eip" "web_eip" {
  instance = aws_instance.web.id
  domain   = "vpc"
}

resource "aws_instance" "web" {
  ami           = "ami-0c3fd0f5d33134a76"
  instance_type = "t2.micro"

  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = aws_key_pair.my_key.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y

              # Apache & PHP
              amazon-linux-extras enable php8.0
              yum clean metadata
              yum install -y httpd php php-mysqlnd
              systemctl start httpd
              systemctl enable httpd

              # MySQL (MariaDB)
              yum install -y mariadb105-server
              systemctl start mariadb
              systemctl enable mariadb

              # DB作成
              mysql -e "CREATE DATABASE wordpress;"
              mysql -e "CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'password';"
              mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';"
              mysql -e "FLUSH PRIVILEGES;"

              # WordPress
              cd /var/www/html
              wget https://wordpress.org/latest.tar.gz
              tar -xzf latest.tar.gz
              cp -r wordpress/* .

              chown -R apache:apache /var/www/html

              # wp-config 作成
              cd /var/www/html

              cp wp-config-sample.php wp-config.php

              sed -i "s/database_name_here/wordpress/" wp-config.php
              sed -i "s/username_here/wpuser/" wp-config.php
              sed -i "s/password_here/password/" wp-config.php

              # Apache再起動
              systemctl restart httpd

              EOF
  tags = {
    Name = "takao-ec2"
  }
}