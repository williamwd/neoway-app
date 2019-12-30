provider "aws" {
    region = var.region
}

data "local_file" "ssh_key" {
    filename = var.ssh_key_path
}
