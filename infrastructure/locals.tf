locals {
  common_prefix = "fastcampus-infra"
  region        = "ap-northeast-2"

  eks_cluster_version = "1.29"
  eks_ng_min_size     = 5
  eks_ng_max_size     = 5
  eks_ng_desired_size = 5
  eks_instance_type   = "t3.medium"

  rds_engine_version    = "16.2"
  rds_instance_class    = "db.t3.micro"
  rds_allocated_storage = 20
}
