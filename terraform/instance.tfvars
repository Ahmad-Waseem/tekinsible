
#--------- image of hardware reqs {each should be same length}


engine_ami_name = "ubuntu22 -old"


engine_ami = "ami-003932de22c285676"

engine = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]

engine_virtualization_type = ["hvm"]

engine_root_device_type = ["ebs"]

engine_owner = ["amazon"]

# -------- http route
openIp = "http://ipv4.icanhazip.com"

# -------- 

aws_ec2_tier = "t2.micro"


# ------- subnet number to connect
subnet_count = 1

