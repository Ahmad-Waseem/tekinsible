#------------- >Terraform state

terraform {
  backend "s3" {
    bucket = "terra-byte-storage"
    key    = "tekinsible007"
    region = var.region
  }
}


# resource "aws_s3_bucket" "terraform_state" {

#   bucket = var.bucket_name

#   lifecycle {
#     prevent_destroy = false
#   }
# }

# resource "aws_s3_bucket_versioning" "terraform_state" {
#   bucket = aws_s3_bucket.terraform_state.id

#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_dynamodb_table" "terraform_state_lock" {
#   name           = var.dynamodb_table_name
#   read_capacity  = 1
#   write_capacity = 1
#   hash_key       = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }