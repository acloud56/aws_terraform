terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.38"
    }
  }
}

# Documentation: https://www.terraform.io/docs/language/providers/requirements.html
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      cs_terraform_examples = "aws_db_instance/simple"
    }
  }
}

resource "aws_db_instance" "changeme_simple_aws_db_instance" {
  allocated_storage   = 5
  engine              = "mysql"
  engine_version      = "5.7"
  instance_class      = "db.t3.micro"
  name                = "changeme_simple_aws_db_instance"
  username            = "changemeusername"
  password            = "changeme_password"
  skip_final_snapshot = true
}
