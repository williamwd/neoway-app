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
