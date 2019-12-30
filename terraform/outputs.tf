output "ecr-registry" {
    value = aws_ecr_repository.neoway-app-registry.repository_url
}

output "elastic-beanstalk-cname" {
    value = aws_elastic_beanstalk_environment.ebs-env.cname
}
