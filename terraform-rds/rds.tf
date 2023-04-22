resource "aws_db_subnet_group" "avs_rds_subnet_group" {
  name       = "avs_rds_subnet_group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Environment = "test"
  }
}

resource "aws_db_instance" "primary_rds_instance" {
  depends_on = [
    aws_db_subnet_group.avs_rds_subnet_group
  ]
  allocated_storage        = 100
  engine                   = "postgres"
  engine_version           = "14.4"
  instance_class           = var.rds_instance_type
  db_name                  = "db_paula"
  identifier               = "avs-db-paula"
  username                 = "db_user_admin"
  password                 = "123456789"
  skip_final_snapshot      = true
  delete_automated_backups = true
  copy_tags_to_snapshot    = true
  backup_retention_period  = 15
  db_subnet_group_name     = aws_db_subnet_group.avs_rds_subnet_group.id
  vpc_security_group_ids   = [aws_security_group.rds.id]

  # storage_encrypted = true

  snapshot_identifier = try(var.rds_snapshop_id, null)

  

  tags = {
    Environment = "Paula_test"
  }
}

## Read replicas
resource "aws_db_instance" "main_read_replica" {
  # read replica
  depends_on = [
    aws_db_instance.primary_rds_instance,
    aws_db_subnet_group.avs_rds_subnet_group
  ]
  replicate_source_db          = aws_db_instance.primary_rds_instance.id
  instance_class               = var.rds_instance_type
  identifier                   = "avs-db-replica-read-backend"
  delete_automated_backups     = true
  performance_insights_enabled = true
  skip_final_snapshot      = true

  tags = {
    Name        = "avs-db-replicas-read-backend"
  }
}