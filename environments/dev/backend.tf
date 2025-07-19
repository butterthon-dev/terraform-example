terraform {
  backend "s3" {
    bucket  = "terraform-example-dev-tfstate"
    region  = "ap-northeast-1"
    key     = "default.tfstate"
    profile = "butterthon-dev"
  }
}
