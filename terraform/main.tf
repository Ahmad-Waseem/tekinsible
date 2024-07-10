terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS-Provider
provider "aws" {
  region = var.region
}

#============================> INIT VPC
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "terra-vpc"
    Terraform   = "true"
    Environment = "dev"
  }
}


#------------> DECLARE SUBNETS

#can init subnets with vpc using 'module'
#   !______ But id conflicts with NAT Attachemnt

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-subnet-${count.index + 1}"
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]



  tags = {
    Name        = "private-subnet-${count.index + 1}"
    Terraform   = "true"
    Environment = "dev"
  }
}



#--------------> internet gateway init
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id


  tags = {
    Name = "main"
  }
}

# #---------------> GATEWAY ATTACH

# resource "aws_internet_gateway_attachment" "gw_attach" {
#   internet_gateway_id = aws_internet_gateway.gw.id
#   vpc_id              = aws_vpc.main.id
# }

# ------------> PUBLIC ROUTE TABLE INIT
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    cidr_block = var.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "Public Route Table"
  }
} # public uses two cidrs atleast, global and local


# ------------> Attach public subnets with route table
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public[*].id)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# ------------> Private ROUTE TABLE INIT
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id


  tags = {
    Name = "Private Route Table"
  }
} # public uses two cidrs atleast, global and local


# ------------> Attach private subnets with route table
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private[*].id)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}



# <=================== VPC SETUP COMPLETE






