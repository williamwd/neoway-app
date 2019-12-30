resource "aws_elastic_beanstalk_application" "ebs-app" {
  name        = "${var.key}-beanstalk"
  description = "Application test"
}

data "aws_elastic_beanstalk_solution_stack" "single_docker" {
  most_recent = true
  name_regex = "^64bit Amazon Linux (.*) v(.*) running Docker (.*)$"
}

resource "aws_key_pair" "neoway-app-ssh-key" {
  key_name   = "${var.key}-ssh-key"
  public_key = data.local_file.ssh_key.content
}


resource "aws_elastic_beanstalk_environment" "ebs-env" {
    name = "${var.key}-env"
    application = aws_elastic_beanstalk_application.ebs-app.name
    tier = "WebServer"
    solution_stack_name = data.aws_elastic_beanstalk_solution_stack.single_docker.name

    setting {
        namespace = "aws:elasticbeanstalk:environment"
        name = "ServiceRole"
        value = aws_iam_role.neoway-app-role.arn
    }

    setting {
        namespace = "aws:elasticbeanstalk:environment"
        name = "EnvironmentType"
        value = "SingleInstance"
    }

    setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name = "IamInstanceProfile"
        value = aws_iam_instance_profile.ec2-ecr-profile.name
    }

    setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name = "EC2KeyName"
        value = aws_key_pair.neoway-app-ssh-key.key_name
    }

    setting {
        namespace = "aws:ec2:vpc"
        name = "VPCId"
        value = aws_vpc.neoway-app-vpc.id
    }

    setting {
        namespace = "aws:ec2:vpc"
        name = "Subnets"
        value = aws_subnet.neoway-app-subnet.1.id
    }

    setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name = "SecurityGroups"
        value = aws_security_group.neoway-app-ebs-sg.id
    }
}
