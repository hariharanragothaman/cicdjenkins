provider "aws" {
  profile = "default"
  region  = var.aws_region
}

# Configuring security groups

resource "aws_security_group" "web_traffic" {
  name        = var.aws_security_group_name
  description = "Allow ssh and standard http/https ports inbound and everything outbound"

  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" = "true"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.web_traffic.name]
  # Create a key-pair ni the Amazon EC2 Console: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair
  # Ensure key-pairs are in the same-region otherwise a 400 will be generated
  key_name        = var.aws_key_pair_name
  # Execute Remote commands inside the grabbed instance using "remote-exec" provisioner
  provisioner "remote-exec" {
    inline = [
      "ls",
    ]
  } 

  # Allowing Connection through SSH
 connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("~/Downloads/${var.aws_key_pair_name}.pem")
  }
 tags = {
    "Name"      = var.project_name
    "Terraform" = "true"
  }
}