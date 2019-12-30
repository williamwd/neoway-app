# Players APP

A simple web server where users can track how many games players have won.

This code was extracted from [Learn Go With Tests](https://quii.gitbook.io/learn-go-with-tests/build-an-application/http-server).

## Getting Started

### Prerequisites

- [Golang](http://golang.org/) (>1.10)
- [GNU Make](https://www.gnu.org/software/make/)
- [Docker](http://docker.com)

### Running locally

```bash
make run
```

## Running tests and check coverage

```bash
make test
```

## Deployment

### Build

```bash
make image VERSION=x.x.x
```

### Tag and publish image

```bash
make pubish VERSION=x.x.x
```

### Run registry image locally

```bash
make run-docker VERSION=x.x.x
```

### Endpoints


- `GET /players/{name}` should return a number indicating the total number of wins
- `POST /players/{name}` should record a win for that name, incrementing for every subsequent `POST`

## Infrastructure provisioning

You have the option to provision a cloud infrastructure with a pipeline and server infrastructure and run it on AWS. All you need is terraform >= 0.12, aws-cli configured on your machine, a public ssh key and a GitHub Personal access token.

Configure it changing the respective values on "main.tfvars", then use the following commands to provision the infrastructure.

### Init terraform inside its folder
```bash
terraform init
```

### Run terraform plan to check what will be deployed (also check for errors within the variables)
```bash
terraform plan --var-file=main.tfvars
```

### Apply it!

If everything looks good with the plan, you can apply it. Watch out for unwanted charges on your AWS account.

```bash
terraform apply --var-file=main.tfvars
```

After provisioning it you must configure the correct Docker registry. This happens because the necessary URL is not available before provisioning the ECR service. The URL will be output from the previous command, but you can output it again using:

```bash
terraform output
```

On the provisioned environment it will be configured automatically, but if you want to generate the images locally, you must set the environment variable "PROVISIONED_REGISTRY"

```bash
export PROVISIONED_REGISTRY=<Output ECR URL>
```

### SSH Access

The CNAME from the provisioned environment will be output from terraform apply, but in order to connect you must know that the ssh user is "ec2-user", as it is running an Amazon Linux

### Destroying it

If you want to destroy the provisioned environment, just let terraform do it for you. Note that empty S3 buckets will not be deleted automatically

```bash
terraform destroy --var-file=main.tfvars
```

### Important notes

- If you don't specify the --var-file, Terraform will ask you to enter manually all variables contained in that file
- Please consider your application security by configuring your public IP on "main.tfvars", so only connections from your public IP would reach your server instance. You can get your public IP with the following command on Linux

```bash
dig +short myip.opendns.com @resolver1.opendns.com
```
