variable "ec2_instance_type" {
  description = "AWS Instance Size"
  default = "t2.micro"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default = "us-east-1"
}