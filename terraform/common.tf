provider "aws" {
    region  = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "atg-terraform-remote-state"
    key    = "pathto-x/terraform.tfstate"
    region = "us-east-1"
  }
}