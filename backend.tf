terraform {

  backend "s3" {
    bucket = "terra-state-dynamic-web"
    key = "terraform-state"
    region = "us-east-1"
  }
}