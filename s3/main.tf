################################################
#      Simple Storage Service (S3)             #                                       
################################################

provider "aws" {
  region = "ap-southeast-1"
}
//Create a S3 bucket
resource "aws_s3_bucket" "S3bucket" {
  bucket = "${var.s3_bucket_name}-${random_id.S3_random_id.dec}"
  acl = "private"    //Default value. Other values include public-read and public-read-write.
  versioning {
      enabled = true
  }

  lifecycle_rule {   //Create a lifecycle rule for storage life management.
      enabled = true
      transition {
          days = 5
          storage_class = "STANDARD_IA"
      }
      transition {
          days = 15
          storage_class = "GLACIER"
      }
      expiration {
          days = 20
      }

  tags = {
      Name = "haicasgox"
      Environment = "Test"
        }
  } 
}
//Create a random id to prevent the S3 bucket to collide with others.
resource "random_id" "S3_random_id" {
  byte_length = 8  //The number of random bytes to produce. The minimum value is 1
}
