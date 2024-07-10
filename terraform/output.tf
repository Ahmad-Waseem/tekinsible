
# ------------> Outputs for VPC init
output "ec2_public_ip" {
  value       = aws_instance.web.public_ip
  description = "The public IP address of the EC2 instance"
}

output "ec2_public_dns" {
  value       = aws_instance.web.public_dns
  description = "The public DNS name of the EC2 instance"
}

output "ec2_private_ip" {
  value       = aws_instance.web.private_ip
  description = "The private IP address of the EC2 instance"
}

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the VPC"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "The IDs of the public subnets"
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "The IDs of the private subnets"
}

# output "s3_bucket_name" {
#   value       = aws_s3_bucket.terraform_state.bucket
#   description = "The name of the S3 bucket used for Terraform state storage"
# }

# output "dynamodb_table_name" {
#   value       = aws_dynamodb_table.terraform_state_lock.name
#   description = "The name of the DynamoDB table used for Terraform state locking"
# }