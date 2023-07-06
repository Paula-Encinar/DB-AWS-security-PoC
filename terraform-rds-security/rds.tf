resource "aws_db_subnet_group" "avs_rds_subnet_group" {
  name       = "avs-rds-subnet-group-${var.environment}"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Environment = var.environment
  }
}

resource "aws_db_instance" "primary_rds_instance" {
  depends_on = [
    aws_db_subnet_group.avs_rds_subnet_group
  ]
  allocated_storage        = 20
  engine                   = "postgres"
  engine_version           = "14.4"
  instance_class           = var.rds_instance_type
  db_name                  = "postgres"
  identifier               = "avs-db-${var.environment}"
  username                 = "db_user_admin"
  password                 = random_password.random_admin_password.result
  skip_final_snapshot      = true
  delete_automated_backups = true
  copy_tags_to_snapshot    = true
  backup_retention_period  = 15
  db_subnet_group_name     = aws_db_subnet_group.avs_rds_subnet_group.id
  vpc_security_group_ids   = [aws_security_group.rds.id]
  # storage_encrypted = true
  snapshot_identifier = try(var.rds_snapshop_id, null)
  tags = {
    Environment = var.environment
  }
}
