locals {
  common_prefix = "fastcampus-infra"
  region        = "ap-northeast-2"

  eks_cluster_version = "1.29"
  eks_ng_min_size     = 2
  eks_ng_max_size     = 2
  eks_ng_desired_size = 2
  eks_instance_type   = "t3.medium"
}
