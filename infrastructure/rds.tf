resource "aws_db_instance" "rds" {
  identifier             = "${local.common_prefix}-db"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
  parameter_group_name   = aws_db_parameter_group.rds_parameter_group.name
  vpc_security_group_ids = [module.eks.cluster_security_group_id]

  engine         = "mysql"
  engine_version = local.rds_engine_version
  instance_class = local.rds_instance_class

  storage_type      = "gp3"
  allocated_storage = local.rds_allocated_storage

  db_name  = "sample"
  username = "fastcampus"
  password = "supersecretpassword"
  port     = "3306"

  backup_retention_period = 7

  iam_database_authentication_enabled = false
  skip_final_snapshot                 = true
  deletion_protection                 = false
  publicly_accessible                 = false

  tags = {
    Name       = "${local.common_prefix}-db"
    Fastcampus = "true"
  }
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${local.common_prefix}-db-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name       = "${local.common_prefix}-db-subnet-group"
    Fastcampus = "true"
  }
}


resource "aws_db_parameter_group" "rds_parameter_group" {
  name   = "${local.common_prefix}-db-parameter-group"
  family = "mysql8.0"

  parameter {
    name  = "binlog_format"
    value = "ROW"
  }

  tags = {
    Name       = "${local.common_prefix}-db-parameter-group"
    Fastcampus = "true"
  }
}