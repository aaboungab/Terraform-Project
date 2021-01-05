#Azure as provider
provider "azurerm" {
  features {}
}
module "london-scaleset" {
  source      = "./scaleset"
  location    = "uksouth"
  prefix      = "london"
  in          = "9"
  inmins      = "0"
  out         = "17"
  outmins     = "0"
  environment = "production"
}
module "paris-scaleset" {
  source      = "./scaleset"
  location    = "francecentral"
  prefix      = "paris"
  in          = "10"
  inmins      = "0"
  out         = "15"
  outmins     = "0"
  environment = "staging"
}
module "mumbai-scaleset" {
  source      = "./scaleset"
  location    = "eastasia"
  prefix      = "mumbai"
  in          = "2"
  inmins      = "30"
  out         = "10"
  outmins     = "30"
  environment = "development"
}