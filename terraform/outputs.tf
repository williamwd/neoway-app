output "ecr-registry" {
    value = aws_ecr_repository.neoway-app-registry.repository_url
}
