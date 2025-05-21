resource "aws_s3_bucket" "prod" {
  bucket = "myapp-static-prod"
}

resource "aws_s3_bucket" "staging" {
  bucket = "myapp-static-staging"
}
