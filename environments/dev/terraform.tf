terraform {
  required_version = "~> 1.12.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "butterthon-dev"
}

provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = "butterthon-dev"
}

data "aws_caller_identity" "current" {}
