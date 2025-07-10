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

resource "azurerm_web_app_source_control" "github_deploy" {
  name                = azurerm_web_app.westWebApp.name
  resource_group_name = azurerm_resource_group.rg.name
  repo_url            = "https://github.com/WildPoro/Azure-Web-App-High-Availability"
  branch              = "main"
  use_manual_integration = true
  use_mercurial           = false
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

resource "azurerm_app_service_plan" "WestAppPlan"{
  name = "WestAppPlanKristianZ"
  location = "westus"
  resource_group_name = azurerm_resource_group.rg.name
  sku{
    tier = "Standard"
    size = "S1"
  }
}
resource "azurerm_app_service_plan" "EastAppPlan"{
  name = "EastAppPlanKristianZ"
  location = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
  sku{
    tier = "Standard"
    size = "S1"
  }
}
resource "azurerm_web_app" "westWebApp" {
  name                = "westWebAppZotka"
  location            = "westus"
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.WestAppPlan.id

  https_only = true
}

resource "azurerm_web_app" "eastWebApp" {
  name                = "eastWebAppZotka"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.EastAppPlan.id

  https_only = true
}

resource "azurerm_traffic_manager_azure_endpoint" "east" {
  name                = "eastendpoint"
  profile_id          = azurerm_traffic_manager_profile.profile.id
  target_resource_id  = azurerm_storage_account.eastWebApp.id
}

resource "azurerm_traffic_manager_azure_endpoint" "west" {
  name                = "westendpoint"
  profile_id          = azurerm_traffic_manager_profile.profile.id
  target_resource_id = azurerm_storage_account.westWebApp.id
}
