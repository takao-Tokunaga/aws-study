resource "aws_iam_role" "ec2_role" {
    name = "takao-case2-ec2-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect  = "Allow"
            Principal = { Service = "ec2.amazonaws.com" }
            Action    = "sts:AssumeRole"
        }]
    })
}

resource "aws_iam_role_policy_attachment" "ssm" {
    role       = aws_iam_role.ec2_role.name 
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
    name = "takao-case2-ec2-profile"
    role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "web" {
    ami                         = "ami-0c3fd0f5d33134a76"
    instance_type               = "t2.micro"
    subnet_id                   = aws_subnet.private_1a.id
    vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
    iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
    user_data_replace_on_change = true

    user_data = <<-EOF
#!/bin/bash
yum update -y
amazon-linux-extras enable php8.0
yum clean metadata
yum install -y httpd php php-mysqlnd
systemctl enable httpd
systemctl start httpd

cd /var/www/html
wget -q https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* .
rm -rf wordpress latest.tar.gz

cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/wordpress/" wp-config.php
sed -i "s/username_here/wpuser/" wp-config.php
sed -i "s/password_here/${var.db_password}/" wp-config.php
sed -i "s/localhost/${aws_db_instance.wordpress.address}/" wp-config.php

CF_URL="https://${aws_cloudfront_distribution.cf.domain_name}"
{
  echo "<?php"
  echo "define('WP_HOME','$CF_URL');"
  echo "define('WP_SITEURL','$CF_URL');"
  printf "\x24_SERVER['HTTPS'] = 'on';\n"
  tail -n +2 wp-config.php
} > /tmp/wp-config-new.php
mv /tmp/wp-config-new.php wp-config.php

chown -R apache:apache /var/www/html
systemctl restart httpd
EOF

   tags = {
    Name = "takao-case2-ec2"
   }
}
