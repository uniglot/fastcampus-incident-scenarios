output "eks_endpoint" {
  value = module.eks.cluster_endpoint
}

output "ecr_url" {
  value = resource.aws_ecr_repository.application_images.repository_url
}