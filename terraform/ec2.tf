# ======================================> SETTING EC2 INSTANCE


# ----------------> Allocating Hardware Image
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = var.engine
  }

  filter {
    name   = "virtualization-type"
    values = var.engine_virtualization_type
  }

  filter {
    name   = "root-device-type"
    values = var.engine_root_device_type
  }

  owners = var.engine_owner
}

# ---------------------> Get the current IP address
data "http" "my_ip" {
  url = var.openIp #currently going to ican
}

# ---------------------> create a security group that allows SSH access from your IP
resource "aws_security_group" "ssh_access" {
  name        = "Allow SSH"
  description = "Allow SSH access from your IP"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #["${chomp(data.http.my_ip.response_body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow SSH"
  }
}

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-> Ec2 instance

resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.aws_ec2_tier
  subnet_id                   = aws_subnet.public[var.subnet_count].id
  associate_public_ip_address = true
  key_name                    = var.keypairname

  vpc_security_group_ids = [
    aws_security_group.ssh_access.id
  ]

  tags = {
    Name = "t2_micro_ec2"
  }
}
