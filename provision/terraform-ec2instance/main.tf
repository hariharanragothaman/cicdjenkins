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

      /*  Setup Docker */
      "sudo apt-get update",
      "sudo apt-get install curl",
      "sudo curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo DRY_RUN=1 sh ./get-docker.sh",

      /* Build Docker Image and run container in port 8080*/
      "sudo docker build -t jenkins:jcasc jenkinsDockerSetup",
      "sudo docker run --name jenkins --rm -p 8080:8080 --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD=password jenkins:jcasc",

      # install remaining dependencies
      "sudo apt -y install nginx",
      "sudo apt -y install ufw",

      /*
      "sudo apt-get --assume-yes install jenkins",
      # Add LOGIC for IPTABLES
      "sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080",
      "sudo sh -c \"iptables-save > /etc/iptables.rules\"",
      "echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections",
      "echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections",
      "sudo apt-get -y install iptables-persistent",
      "sudo ufw allow 8080",
      */
      # setup debian firewall
      "sudo ufw status verbose",
      "sudo ufw default deny incoming",
      "sudo ufw default allow outgoing",
      "sudo ufw allow ssh",
      "sudo ufw allow 22",
      "sudo ufw allow 80",
      "sudo yes | ufw enable",

      # update nginx configuration
      "sudo rm -f /etc/nginx/sites-enabled/default",
      "sudo cp -f /tmp/jenkins-proxy /etc/nginx/sites-enabled",
      "sudo service nginx restart"

    ]
  } 

  # Allowing Connection through SSH
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