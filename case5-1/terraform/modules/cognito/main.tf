resource "aws_cognito_user_pool" "user_pool" {
    name = "${var.project}-cognito"
    password_policy {
        minimum_length    = 8
        require_lowercase = true
        require_uppercase = true
        require_numbers   = true
        require_symbols   = true
    }
    mfa_configuration = "ON"
    auto_verified_attributes = [
        "email",
    ]
    email_mfa_configuration {
      message = "Your verification code is {####}"
      subject = "Your verification code"
    }

    email_configuration {
      email_sending_account = "DEVELOPER"
      source_arn            = "arn:aws:ses:ap-northeast-1:058898200941:identity/tokunagao749@gmail.com"
    }
}

resource "aws_cognito_user_pool_client" "app" {
    name = "${var.project}-client"
    user_pool_id = aws_cognito_user_pool.user_pool.id

    explicit_auth_flows = [
        "ALLOW_USER_SRP_AUTH",
        "ALLOW_USER_PASSWORD_AUTH",
        "ALLOW_REFRESH_TOKEN_AUTH",
    ]

    token_validity_units {
      access_token  = "minutes"
      id_token      = "minutes"
      refresh_token = "minutes"
    }
    // トークン有効期限
    access_token_validity  = 10
    id_token_validity      = 10
    refresh_token_validity = 60
}