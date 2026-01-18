terraform {

  backend "s3" {
    bucket = "terra-state-dynamic"
    key = "terraform-state"
    region = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}