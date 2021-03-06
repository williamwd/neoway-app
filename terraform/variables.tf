variable "key" {
    type = string
}

variable "region" {
    type = string
}

variable "repo_owner" {
    type = string
}

variable "repo_name" {
    type = string
}

variable "repo_branch" {
    type = string
}

variable "ssh_allowed_ips" {
    type = list
}

variable "ssh_key_path" {
    type = string
}

variable "github_auth" {
    type = string
}
