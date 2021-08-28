provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# Configuring security groups

variable "ingressrules" {
  type    = list(number)
  default = [80, 443, 22]
}

resource "aws_security_group" "web_traffic" {
  name        = "Allow web traffic"
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
  key_name        = "cicdterraform"
  
  # Execute Remote commands inside the grabbed instance using "remote-exec" provisioner
  provisioner "remote-exec" {
    inline = [
      "wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
      "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
      "sudo apt-get update",
      "sudo add-apt-repository universe",
      "sudo apt-get update",
      "sudo apt install --assume-yes openjdk-11-jdk",
      "sudo apt-get --assume-yes install jenkins",

      # Add Logic here to configure jenkins and its plugins
      # Take the configuration as code path
      "AUTHSTRING = -auth admin:$(cat /mnt/jenkins/jenkins/secrets/initialAdminPassword)",
      "echo AUTH STRING: $AUTH_STRING > /mnt/jenkins/jenkins/auth_string",
      

      "sudo systemctl start jenkins",
      "sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080",
      "sudo sh -c \"iptables-save > /etc/iptables.rules\"",
      "echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections",
      "echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections",
      "sudo apt-get -y install iptables-persistent",
      "sudo ufw allow 8080",
    ]
  } 

 connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("~/Downloads/cicdterraform.pem")
  }
 tags = {
    "Name"      = "Jenkins_Server"
    "Terraform" = "true"
  }
}
