provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "codepipeline_bucket" {
    bucket = "pipeline-bucket"
    acl    = "private"
}

resource "aws_iam_role" "neoway-app-role" {
    name = "neoway-app-role"

    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "codepipeline.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "neoway-app-policy" {
    name = "neoway-app-policy"
    role = "${aws_iam_role.neoway-app-role.id}"

    policy = <<POLICY
{
    "Statement": [
        {
            "Action": [
                "iam:PassRole"
            ],
            "Condition": {
                "StringEqualsIfExists": {
                    "iam:PassedToService": [
                        "cloudformation.amazonaws.com",
                        "elasticbeanstalk.amazonaws.com",
                        "ec2.amazonaws.com",
                        "ecs-tasks.amazonaws.com"
                    ]
                }
            },
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "codecommit:CancelUploadArchive",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:UploadArchive"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplication",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "codebuild:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "codestar-connections:UseConnection"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "ec2:*",
                "elasticloadbalancing:*",
                "autoscaling:*",
                "cloudwatch:*",
                "logs:*",
                "s3:*",
                "sns:*",
                "cloudformation:*",
                "rds:*",
                "sqs:*",
                "ecs:*",
                "ecr:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "lambda:InvokeFunction",
                "lambda:ListFunctions"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "opsworks:CreateDeployment",
                "opsworks:DescribeApps",
                "opsworks:DescribeCommands",
                "opsworks:DescribeDeployments",
                "opsworks:DescribeInstances",
                "opsworks:DescribeStacks",
                "opsworks:UpdateApp",
                "opsworks:UpdateStack"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "cloudformation:CreateStack",
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStacks",
                "cloudformation:UpdateStack",
                "cloudformation:CreateChangeSet",
                "cloudformation:DeleteChangeSet",
                "cloudformation:DescribeChangeSet",
                "cloudformation:ExecuteChangeSet",
                "cloudformation:SetStackPolicy",
                "cloudformation:ValidateTemplate"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "devicefarm:ListProjects",
                "devicefarm:ListDevicePools",
                "devicefarm:GetRun",
                "devicefarm:GetUpload",
                "devicefarm:CreateUpload",
                "devicefarm:ScheduleRun"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "servicecatalog:ListProvisioningArtifacts",
                "servicecatalog:CreateProvisioningArtifact",
                "servicecatalog:DescribeProvisioningArtifact",
                "servicecatalog:DeleteProvisioningArtifact",
                "servicecatalog:UpdateProduct"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "cloudformation:ValidateTemplate"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "ecr:DescribeImages"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ],
    "Version": "2012-10-17"
}
POLICY

}

resource "aws_ecs_cluster" "neoway-app" {
    name = "neoway-app"
}

resource "aws_ecs_service" "neoway-app" {
    name = "neoway-app"
    task_definition = "${aws_ecs_task_definition.this.id}"
    cluster = "${aws_ecs_cluster.neoway-app.arn}"

    launch_type   = "FARGATE"
    desired_count = 1

    network_configuration {
        subnets         = ["${aws_subnet.neoway-app.*.id}"]
        security_groups = ["${aws_security_group.ecs.id}"]

        assign_public_ip = true
    }
}

resource "aws_codebuild_project" "neoway-app-codebuild" {
    name          = "neoway-app-codebuild"
    description   = "Neoway app codebuild project"
    build_timeout = "5"
    service_role  = "${aws_iam_role.neoway-app-role.arn}"

    artifacts {
        type = "CODEPIPELINE"
    }

    cache {
        type     = "S3"
        location = "${aws_s3_bucket.codepipeline_bucket.bucket}"
    }

    environment {
        compute_type                = "BUILD_GENERAL1_SMALL"
        image                       = "aws/codebuild/standard:3.0"
        type                        = "LINUX_CONTAINER"
        privileged_mode             = "true"
    }

    source {
        type            = "CODEPIPELINE"
    }

    tags = {
        name = "neoway-app-build"
    }
}

data "aws_kms_alias" "s3kmskey" {
    name = "alias/kmsKey"
}

resource "aws_codepipeline" "nw-pipeline" {
    name     = "nw-pipeline"
    role_arn = "${aws_iam_role.neoway-app-role.arn}"

    artifact_store {
        location = "${aws_s3_bucket.codepipeline_bucket.bucket}"
        type     = "S3"

        encryption_key {
            id   = "${data.aws_kms_alias.s3kmskey.arn}"
            type = "KMS"
        }
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
                Owner  = "williamwd"
                Repo   = "neoway-app"
                Branch = "master"
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
                ProjectName = "${aws_codebuild_project.neoway-app-codebuild.name}"
            }
        }
    }

    stage {
        name = "Deploy"

        action {
            name            = "Deploy"
            category        = "Deploy"
            owner           = "AWS"
            provider        = "CodeDeployToECS"
            version         = "1"
            input_artifacts = ["build"]

            configuration {
                ApplicationName                = "${aws_codedeploy_app.this.name}"
                DeploymentGroupName            = "${aws_codedeploy_deployment_group.this.deployment_group_name}"
                TaskDefinitionTemplateArtifact = "build"
                AppSpecTemplateArtifact        = "build"
            }
        }
        }
}
