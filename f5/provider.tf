terraform {
  required_providers {
    bigip = {
      source = "terraform-providers/bigip"
    }
  }
  required_version = ">= 0.13"
}

provider "bigip" {
  address  = "10.96.94.218"
  username = "acloud"
  password = "Bigperm6!"
}