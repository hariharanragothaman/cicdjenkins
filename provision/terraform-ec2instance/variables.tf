variable "ingressrules" {
  type    = list(number)
  default = [80, 443, 22]
}

variable "ec2_instance_type" {
  description = "AWS Instance Size"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_security_group_name" {
  description = "AWS Security Group Name"
}