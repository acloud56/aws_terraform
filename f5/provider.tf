terraform {
  required_providers {
    bigip = {
      source = "F5Networks/bigip"
    }
  }
  required_version = ">= 0.13"
}

provider "bigip" {
  address  = "10.96.94.218"
  username = "acloud"
  password = "Bigperm7!"
}
