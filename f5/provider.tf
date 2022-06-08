terraform {
  required_providers {
    bigip = {
      source = "F5Networks/bigip"
      version = "~> 1.10.0"
    }
  }
  required_version = ">= 0.13"
}

provider "bigip" {
  address  = "10.96.94.218"
  username = "acloud"
  password = "Bigperm6!"
}
