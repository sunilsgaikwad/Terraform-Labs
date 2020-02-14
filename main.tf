provider "azurerm" {
  version = "~> 1.33.1"
}

provider "random" {}

resource "random_string" "rnd" {
  length = 8
  special = false
  lower = true
  upper = false
}

resource "azurerm_resource_group" "lab1" {
  name     = var.rg
  location = var.loc
  tags = var.tags
}

/*resource "azurerm_storage_account" "bs1sa" {
  name                     = "sa${var.tags["source"]}${random_string.rnd.result}"
  resource_group_name      = azurerm_resource_group.lab1.name
  location                 = azurerm_resource_group.lab1.location
  tags                     = azurerm_resource_group.lab1.tags
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

*/