terraform {
  required_providers {
    bigip = {
      source = "terraform-providers/bigip"
      version = "~> 1.6.0"
    }
  }
  required_version = ">= 0.13"
}

provider "bigip" {
  address  = "10.96.94.218"
  username = "acloud"
  password = "Bigperm6!"
}
