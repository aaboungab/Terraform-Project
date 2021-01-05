#Azure as provider
provider "azurerm" {
  features {}
}
module "london-scaleset" {
  source      = "./scaleset"
  location    = "uksouth"
  time_zone = "GMT Standard Time"
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
  time_zone = "Central Europe Standard Time"
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
  time_zone = "India Standard Time"
  prefix      = "mumbai"
  in          = "2"
  inmins      = "30"
  out         = "10"
  outmins     = "30"
  environment = "development"
}