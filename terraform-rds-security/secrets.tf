resource "random_password" "random_admin_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}


resource "aws_secretsmanager_secret" "db_credentials" {
  name = "avs_db_credentials-${var.environment}2"

  tags = {
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "db_json_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username             = "db_user_admin"
    password             = random_password.random_admin_password.result
    engine               = aws_db_instance.primary_rds_instance.engine
    host                 = aws_db_instance.primary_rds_instance.address
    port                 = aws_db_instance.primary_rds_instance.port
    dbname               = aws_db_instance.primary_rds_instance.db_name
    dbInstanceIdentifier = aws_db_instance.primary_rds_instance.identifier
    old_host             = ""
  })
}
