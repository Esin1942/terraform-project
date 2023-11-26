terraform {
  backend "s3" {
    bucket = "company-wide-storage-illiasoroka"
    key    = "path/to/my/key"
    region = "us-east-1"
  }
}