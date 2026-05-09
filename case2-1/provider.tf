terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~>5.0"
        }
    }
    backend "s3" {
        bucket  = "takao-terraform-tfstate"
        key     = "takao-case2-1.tfstate"
        region  = "ap-northeast-1"
        profile = "default"
    }
}

provider "aws" {
    region  = "ap-northeast-1"
    profile = "default"
}
