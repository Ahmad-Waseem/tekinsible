# ======================================> SETTING EC2 INSTANCE


# ----------------> Allocating Hardware Image
# data "aws_ami" "amazon_linux_2" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = var.engine
#   }

#   filter {
#     name   = "virtualization-type"
#     values = var.engine_virtualization_type
#   }

#   filter {
#     name   = "root-device-type"
#     values = var.engine_root_device_type
#   }

#   owners = var.engine_owner
# }

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

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #["${chomp(data.http.my_ip.response_body)}/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
  ami                         = var.engine_ami
  instance_type               = var.aws_ec2_tier
  subnet_id                   = aws_subnet.public[var.subnet_count].id
  associate_public_ip_address = true
  key_name                    = var.key_pair

  vpc_security_group_ids = [
    aws_security_group.ssh_access.id
  ]

  tags = {
    Name = "t2_micro_ec2"
    ami  = var.engine_ami_name
  }
}




# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-> RUNNING ANSIBLE


data "template_file" "inventory" {
  template = <<-EOT
    [ec2_instances]
    ${aws_instance.web.public_ip} ansible_user=ubuntu ansible_private_key_file= ${var.key_address}/${var.key_pair}.pem
    EOT
}

resource "local_file" "inventory" {
  depends_on = [aws_instance.web]

  filename = "inventory.ini"
  content  = data.template_file.inventory.rendered

  provisioner "local-exec" {
    command = <<EOT
chmod 400 ${local_file.inventory.filename}
echo "Contents of inventory.ini:"
cat ${local_file.inventory.filename}
EOT
  }
}

resource "null_resource" "run_ansible" {
  depends_on = [local_file.inventory]

  provisioner "local-exec" {
    command     = "sleep 30 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini ansible_ec2_config.yaml"
    working_dir = path.module
  }
}
