variable "profile" {
  type        = string
  description = "The profile to use for AWS CLI commands"
}

variable "region" {
  type        = string
  description = "The region to use for AWS CLI commands"
}

variable "vpc_ipv4_address" {
  type        = string
  description = "The IPv4 address of the VPC"
  default     = "192.168.0.0"
}

variable "vpc_ipv4_mask" {
  type        = number
  description = "The IPv4 mask of the VPC"
  default     = 16
}

variable "instance_type" {
  type        = string
  description = "The type of the instance"
}

variable "proxy_username" {
  type        = string
  description = "The username for the proxy"
}

variable "proxy_password" {
  type        = string
  description = "The password for the proxy"
}

variable "proxy_port" {
  type        = number
  description = "The port for the proxy"
  default     = 3128
}