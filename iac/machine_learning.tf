# Project: Intelligent system for monitoring indoor air quality and fight against COVID-19
# Version: 1.0
# Author: Felix Angel Martinez Muela
# https://github.com/terraform-providers/terraform-provider-azurerm

data "azurerm_client_config" "current" {}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/machine_learning_workspace
resource "azurerm_machine_learning_workspace" "airq-mlws" {
  name                    = "airq-mlws"
  location                = azurerm_resource_group.airq-rg.location
  resource_group_name     = azurerm_resource_group.airq-rg.name
  application_insights_id = azurerm_application_insights.airq-ai-ml.id
  key_vault_id            = azurerm_key_vault.airq-kv.id
  storage_account_id      = azurerm_storage_account.airqst.id
  sku_name                = "Basic"
  identity {
    type = "SystemAssigned"
  }
  tags = {
    ApplicationName    = var.application_name
    Env                = var.environment
    Criticality        = "High"
    DataClassification = "Confidential"
    BusinessUnit       = var.business_unit
    Owner              = var.owner
  }
  lifecycle {
    ignore_changes = [
      container_registry_id
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
resource "azurerm_key_vault" "airq-kv" {
  name                = "airq-kv2"
  location            = azurerm_resource_group.airq-rg.location
  resource_group_name = azurerm_resource_group.airq-rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  purge_protection_enabled = true
  tags = {
    ApplicationName    = var.application_name
    Env                = var.environment
    Criticality        = "High"
    DataClassification = "Confidential"
    BusinessUnit       = var.business_unit
    Owner              = var.owner
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/application_insights
resource "azurerm_application_insights" "airq-ai-ml" {
  name                = "workspace-example-ai"
  location            = azurerm_resource_group.airq-rg.location
  resource_group_name = azurerm_resource_group.airq-rg.name
  application_type    = "web"
  tags = {
    ApplicationName    = var.application_name
    Env                = var.environment
    Criticality        = "High"
    DataClassification = "Confidential"
    BusinessUnit       = var.business_unit
    Owner              = var.owner
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory
resource "azurerm_data_factory" "airq-df" {
  name                = "airq-df"
  location            = azurerm_resource_group.airq-rg.location
  resource_group_name = azurerm_resource_group.airq-rg.name
    tags = {
    ApplicationName    = var.application_name
    Env                = var.environment
    Criticality        = "High"
    DataClassification = "Confidential"
    BusinessUnit       = var.business_unit
    Owner              = var.owner
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_linked_service_data_lake_storage_gen2
resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "airq-df-dls" {
  name                  = "airq-df-dls"
  resource_group_name   = azurerm_resource_group.airq-rg.name
  data_factory_name     = azurerm_data_factory.airq-df.name
  tenant                = var.tenant
  url                   = azurerm_storage_account.airqst.primary_dfs_endpoint
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_linked_service_cosmosdb
resource "azurerm_data_factory_linked_service_cosmosdb" "airq-df-cdb" {
  name                = "airq-df-cdb"
  resource_group_name = azurerm_resource_group.airq-rg.name
  data_factory_name   = azurerm_data_factory.airq-df.name
  account_endpoint    = azurerm_cosmosdb_account.airq-cosmos.endpoint
  account_key         = azurerm_cosmosdb_account.airq-cosmos.primary_key
  database            = "airq-db"
}
