resource "aws_db_subnet_group" "avs_rds_subnet_group" {
  name       = "avs_rds_subnet_group_${var.environment}"
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
  db_name                  = "db_avs_${var.environment}"
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


# # rds backup lambda execution role
# resource "aws_iam_role" "rds_backup_lambda_execution_role" {
#   assume_role_policy = jsonencode(
#     {
#       Statement = [
#         {
#           Action = "sts:AssumeRole"
#           Effect = "Allow"
#           Principal = {
#             Service = "lambda.amazonaws.com"
#           }
#         },
#       ]
#       Version = "2012-10-17"
#     }
#   )
#   name = "${var.environment}-aws-rds-backup-lambda-LambdaExecutionRole"
#   path = "/"
#   tags = {
#     Environment = var.environment
#   }

#   inline_policy {
#     name = "Lambda_execution"
#     policy = jsonencode(
#       {
#         Statement = [
#           {
#             Action = [
#               "logs:*",
#             ]
#             Effect   = "Allow"
#             Resource = "arn:aws:logs:*:*:*"
#           },
#         ]
#         Version = "2012-10-17"
#       }
#     )
#   }
#   inline_policy {
#     name = "ec2_snapshot_policy"
#     policy = jsonencode(
#       {
#         Statement = [
#           {
#             Action = [
#               "ec2:CreateTags",
#               "ec2:UpdateTags",
#               "ec2:DescribeTags",
#               "ec2:DescribeInstances",
#               "ec2:CreateSnapshot",
#               "ec2:DescribeSnapshots",
#               "ec2:DeleteSnapshot",
#               "ec2:DescribeVolumes",
#             ]
#             Effect   = "Allow"
#             Resource = "*"
#           },
#         ]
#         Version = "2012-10-17"
#       }
#     )
#   }
#   inline_policy {
#     name = "rds_snapshot_policy"
#     policy = jsonencode(
#       {
#         Statement = [
#           {
#             Action = [
#               "rds:DescribeDBInstances",
#               "rds:DescribeDBSnapshots",
#               "rds:ListTagsForResource",
#               "rds:DescribeDBSecurityGroups",
#               "rds:CreateDBSnapshot",
#               "rds:DeleteDBSnapshot",
#               "rds:DescribeDBClusterSnapshots",
#               "rds:CreateDBClusterSnapshot",
#               "rds:DeleteDBClusterSnapshot",
#             ]
#             Effect   = "Allow"
#             Resource = "*"
#           },
#         ]
#         Version = "2012-10-17"
#       }
#     )
#   }
#   inline_policy {
#     name = "sns_publish_policy"
#     policy = jsonencode(
#       {
#         Statement = [
#           {
#             Action = [
#               "sns:Publish",
#             ]
#             Effect   = "Allow"
#             Resource = "*"
#           },
#         ]
#         Version = "2012-10-17"
#       }
#     )
#   }
# }

# resource "aws_iam_policy" "rds-full-access-policy" {
#   description = "full access to rds services in London"
#   name        = "${var.environment}-rds-full-access-policy"
#   path        = "/"
#   policy = jsonencode(
#     {
#       Statement = [
#         {
#           Action = "rds:*"
#           Condition = {
#             StringEquals = {
#               "aws:RequestedRegion" = "eu-west-2"
#             }
#           }
#           Effect   = "Allow"
#           Resource = "*"
#           Sid      = ""
#         },
#       ]
#       Version = "2012-10-17"
#     }
#   )
#   tags = {
#     Environment = var.environment
#   }
#   tags_all = {
#     Environment = var.environment
#   }
# }

# resource "aws_iam_role_policy_attachment" "rds-full-access-policy-attachment" {
#   role       = aws_iam_role.rds_backup_lambda_execution_role.name
#   policy_arn = aws_iam_policy.rds-full-access-policy.arn
# }
