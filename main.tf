# NSX-T Manager Credentials
provider "nsxt" { }

module "networking" {
  source = "./networking"
}

module "security" {
  source = "./security"
}