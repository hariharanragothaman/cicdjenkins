variable "ec2_instance_type" {
  description = "AWS Instance Size"
  default = "t2.micro"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default = "us-east-1"
}

variable "aws_security_group" {
  description = "AWS Security Group Name"
  default = "Allow web traffic"
}