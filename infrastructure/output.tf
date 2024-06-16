output "eks_endpoint" {
  value = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  description = "address:port"
  value       = resource.aws_db_instance.rds.endpoint
}

output "ecr_url" {
  value = resource.aws_ecr_repository.application_images.repository_url
}