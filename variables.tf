variable "AWS_ACCESS_KEY" {
  type = string
}

variable "AWS_SECRET_KEY" {
  type = string
}

variable "region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "vpc_cidr_blocks" {
  type = string
}

variable "subnets" {
  type = list(object({
    name                    = string
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))
}

variable "igw" {
  type = string
}

variable "instance_type" {
  type = string
}