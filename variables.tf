variable "organization" {
  type = string
}

variable "credentials" {
  type = object({
    access_key = string
    secret_key = string

  })
}

variable "region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "vpc" {
  type = object({
    name        = string
    cidr_blocks = string
  })
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

variable "rtb" {
  type = object({
    name       = string
    cidr_block = string
  })
}

variable "sg_name" {
  type = string
}

variable "instance_type" {
  type = string
}