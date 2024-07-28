resource "aws_db_instance" "rds" {
  identifier           = "${local.common_prefix}-db"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.id
  vpc_security_group_ids = [ module.eks.cluster_security_group_id ]

  engine         = "postgres"
  engine_version = local.rds_engine_version
  instance_class = local.rds_instance_class

  storage_type      = "gp3"
  allocated_storage = local.rds_allocated_storage

  db_name  = "sample"
  username = "fastcampus"
  password = "supersecretpassword"
  port     = "5432"

  iam_database_authentication_enabled = false
  skip_final_snapshot                 = true
  deletion_protection                 = false
  publicly_accessible                 = false
}

resource "aws_db_instance" "new_rds" {
  identifier           = "${local.common_prefix}-db-new"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.id
  vpc_security_group_ids = [ module.eks.cluster_security_group_id ]

  engine         = "postgres"
  engine_version = local.rds_engine_version
  instance_class = local.rds_instance_class

  storage_type      = "gp3"
  allocated_storage = local.rds_allocated_storage

  db_name  = "sample"
  username = "fastcampus"
  password = "supersecretpassword"
  port     = "5432"

  iam_database_authentication_enabled = false
  skip_final_snapshot                 = true
  deletion_protection                 = false
  publicly_accessible                 = false
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${local.common_prefix}-db-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name       = "${local.common_prefix}-db-subnet-group"
    Fastcampus = "true"
  }
}