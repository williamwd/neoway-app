resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.key}-pipeline-bucket"
  acl = "private"
}

resource "aws_ecr_repository" "neoway-app-registry" {
  name = "${var.key}-registry"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_codebuild_project" "neoway-app-codebuild" {
    name          = "neoway-app-codebuild"
    description   = "Neoway app codebuild project"
    build_timeout = "5"
    service_role  = aws_iam_role.neoway-app-role.arn

    artifacts {
        type = "CODEPIPELINE"
    }

    cache {
        type     = "S3"
        location = aws_s3_bucket.codepipeline_bucket.bucket
    }

    environment {
        compute_type    = "BUILD_GENERAL1_SMALL"
        image           = "aws/codebuild/standard:3.0"
        type            = "LINUX_CONTAINER"
        privileged_mode = "true"
    }

    environment_variable {
        name  = "PROVISIONED_REGISTRY"
        value = aws_ecr_repository.neoway-app-registry.repository_url
    }

    source {
        type = "CODEPIPELINE"
    }

    tags = {
        name = "neoway-app-build"
    }
}

resource "aws_codepipeline" "neoway-app-pipeline" {
    name     = "nw-pipeline"
    role_arn = aws_iam_role.neoway-app-role.arn

    artifact_store {
        location = aws_s3_bucket.codepipeline_bucket.bucket
        type     = "S3"
    }

    stage {
        name = "Source"

        action {
            name             = "Source"
            category         = "Source"
            owner            = "ThirdParty"
            provider         = "GitHub"
            version          = "1"
            output_artifacts = ["source_output"]

            configuration = {
                Owner  = var.repo_owner
                Repo   = var.repo_name
                Branch = var.repo_branch
                OAuthToken = var.github_auth
            }
        }
    }

    stage {
    name = "Build"

        action {
            name             = "Build"
            category         = "Build"
            owner            = "AWS"
            provider         = "CodeBuild"
            input_artifacts  = ["source_output"]
            output_artifacts = ["build_output"]
            version          = "1"

            configuration = {
                ProjectName = aws_codebuild_project.neoway-app-codebuild.name
            }
        }
    }

    stage {
        name = "Deploy"

        action {
            name            = "Deploy"
            category        = "Deploy"
            owner           = "AWS"
            provider        = "ElasticBeanstalk"
            version         = "1"
            input_artifacts = ["build_output"]

            configuration = {
                ApplicationName = aws_elastic_beanstalk_application.ebs-app.name
                EnvironmentName = aws_elastic_beanstalk_environment.ebs-env.name
            }
        }
    }
}
