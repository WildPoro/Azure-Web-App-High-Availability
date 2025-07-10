resource "azurerm_resource_group" "rg" {
    name = "testing-rg"
    location = "eastus"
}

resource "azurerm_traffic_manager_profile" "profile"{
    name = "testsingTrafficManager"
    resource_group_name = azurerm_resource_group.rg.name
    traffic_routing_method = "Performance"
   
   dns_config{
        relative_name = "kzotka"
        ttl = 60
   }
   monitor_config{
    protocol = "HTTP"
    port = 80
    path = "/"
   }
}

resource "azurerm_storage_account" "East" {
    name = "eaststorageaccountzotka"
    resource_group_name = azurerm_resource_group.rg.name
    location = "eastus"
    account_tier = "Standard"
    account_replication_type = "LRS"
}

resource "azurerm_storage_account" "West"{
    name = "weststorageaccounzotka"
    resource_group_name = azurerm_resource_group.rg.name
    location = "westus"
    account_tier = "Standard"
    account_replication_type = "LRS"
}

resource "azurerm_traffic_manager_azure_endpoint" "east" {
  name                = "eastendpoint"
  profile_id          = azurerm_traffic_manager_profile.profile.id
  target_resource_id  = azurerm_storage_account.East.id
}

resource "azurerm_traffic_manager_azure_endpoint" "west" {
  name                = "westendpoint"
  profile_id          = azurerm_traffic_manager_profile.profile.id
  target_resource_id  = azurerm_storage_account.West.id
}
