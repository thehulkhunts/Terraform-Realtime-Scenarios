resource "aws_s3_bucket" "bucket-01" {
  bucket = "vin-ultimate-bucket"
  tags = {
    Name = "vin-ultimate-bucket"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket-01.id
  versioning_configuration {
    status = "Enabled"
  }
} 
