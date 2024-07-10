
variable "region" {
  type        = string
  default     = "us-east-2"
  description = "region set to: ohio"
}


variable "cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "cidr block with 6k subnets"
}

variable "public_subnets" {
  type        = list(string)
  default     = ["10.0.8.0/22", "10.0.12.0/22"]
  description = "public nets from tfvars"
}

variable "private_subnets" {
  type        = list(string)
  default     = ["10.0.0.0/22", "10.0.4.0/22"]
  description = "public nets from tfvars"

}

variable "azs" {
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b"]
  description = "azs in tfvars"

}


variable "private_destination" {
  type    = string
  default = "10.0.8.1/22"
}

#-----> Engine_* must have same length to engine

variable "engine_ami" {
  type = string
  description = "AMI's id from AWS WEB"
}

variable "engine_ami_name" {
  type = string
}

variable "engine" {
  type = list(string)
}

variable "engine_virtualization_type" {
  type = list(string)
}


variable "engine_root_device_type" {
  type = list(string)
}

variable "engine_owner" {
  type = list(string)

}

# ---------- http route

variable "openIp" {
  type        = string
  default     = "http://ipv4.icanhazip.com"
  description = "Its a universal domain. It will return your public IP address as a plain text response"
}


# aws instance tier

variable "aws_ec2_tier" {
  type    = string
  default = "t2.micro"
}

# subnet number for aws_instance

variable "subnet_count" {
  type        = number
  default     = 0
  description = "public subnet from all to connect to aws"
}



#key pair variable

variable "key_pair" {
  type        = string
  description = ".pem key file name"
}


variable "bucket_name" {
  type        = string
  description = "s3 bucket name"
}


variable "dynamodb_table_name" {
  type        = string
  description = "dynamo DB table name"
}