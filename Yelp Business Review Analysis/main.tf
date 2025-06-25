provider "aws" {
  region = "us-east-1"
}

# Generate a random suffix to make bucket name globally unique
resource "random_id" "unique_suffix" {
  byte_length = 4
}

# Create the S3 bucket with a unique name
resource "aws_s3_bucket" "yelp_bucket" {
  bucket = "yelp-${random_id.unique_suffix.hex}"
}

# Filter only files starting with "split" from the "current(.) directory
locals {
  files_to_upload = fileset(".", "split*")
}

# Upload each file to S3
resource "aws_s3_object" "upload_split_files" {
  for_each = toset(local.files_to_upload)

  bucket       = aws_s3_bucket.yelp_bucket.bucket
  key          = "uploads/${each.key}"       # Path in S3 bucket
  source       = each.key        # Local file path
  content_type = "application/json"      # You can adjust the content type based on your file types
  etag         = filemd5(each.key)
}

# Output the final bucket name
output "bucket_name" {
  value = aws_s3_bucket.yelp_bucket.bucket
}
