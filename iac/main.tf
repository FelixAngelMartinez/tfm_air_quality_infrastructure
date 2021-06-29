# Project: Intelligent system for monitoring indoor air quality and fight against COVID-19
# Version: 1.0
# Author: Felix Angel Martinez Muela
# https://github.com/terraform-providers/terraform-provider-azurerm

# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

# Configure the Microsoft Azure Provider
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
provider "azurerm" {
  features {}
  environment     = "public"
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "airq-rg" {
  name     = "airq-rg2"
  location = "West Europe"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
resource "azurerm_storage_account" "airqst" {
  name                      = "airqst"
  resource_group_name       = azurerm_resource_group.airq-rg.name
  location                  = azurerm_resource_group.airq-rg.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  access_tier               = "Hot"
  enable_https_traffic_only = "true"
  min_tls_version           = "TLS1_2"
  allow_blob_public_access  = "false"

  tags = {
    ApplicationName    = var.application_name
    Env                = var.environment
    Criticality        = "High"
    DataClassification = "Confidential"
    BusinessUnit       = var.business_unit
    Owner              = var.owner
  }
}

# IoT
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/iothub
resource "azurerm_iothub" "airq-iot-hub2" {
  name                = "airq-iot-hub2"
  resource_group_name = azurerm_resource_group.airq-rg.name
  location            = azurerm_resource_group.airq-rg.location

  sku {
    name     = "F1"
    capacity = "1"
  }

  endpoint {
    type                = "AzureIotHub.ServiceBusQueue"
    connection_string   = azurerm_servicebus_queue_authorization_rule.airq-telemetry-rule.primary_connection_string
    name                = "telemetry-ep"
    resource_group_name = azurerm_resource_group.airq-rg.name
  }

  route {
    name           = "to-telemetry"
    source         = "DeviceMessages"
    condition      = "true"
    endpoint_names = ["telemetry-ep"]
    enabled        = true
  }
  public_network_access_enabled = true

  tags = {
    ApplicationName    = var.application_name
    Env                = var.environment
    Criticality        = "High"
    DataClassification = "Confidential"
    BusinessUnit       = var.business_unit
    Owner              = var.owner
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/iothub_dps
resource "azurerm_iothub_dps" "airq-iot-hub-dps" {
  name                = "airq-iot-hub-dps"
  resource_group_name = azurerm_resource_group.airq-rg.name
  location            = azurerm_resource_group.airq-rg.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  linked_hub {
    connection_string = azurerm_iothub_shared_access_policy.airq-iot-hub-sap.primary_connection_string
    location          = azurerm_resource_group.airq-rg.location
  }

  tags = {
    ApplicationName    = var.application_name
    Env                = var.environment
    Criticality        = "High"
    DataClassification = "Confidential"
    BusinessUnit       = var.business_unit
    Owner              = var.owner
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/iothub_shared_access_policy
resource "azurerm_iothub_shared_access_policy" "airq-iot-hub-sap" {
  name                = "airq-iot-hub-sap"
  resource_group_name = azurerm_resource_group.airq-rg.name
  iothub_name         = azurerm_iothub.airq-iot-hub2.name

  registry_read   = true
  registry_write  = true
  service_connect = true
  device_connect  = true
}

# QUEUE
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace
resource "azurerm_servicebus_namespace" "airq-bus" {
  name                = "airq-bus2"
  location            = azurerm_resource_group.airq-rg.location
  resource_group_name = azurerm_resource_group.airq-rg.name
  capacity            = 0
  zone_redundant      = false
  sku                 = "basic"
  tags = {
    ApplicationName    = var.application_name
    Env                = var.environment
    Criticality        = "High"
    DataClassification = "Confidential"
    BusinessUnit       = var.business_unit
    Owner              = var.owner
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue
resource "azurerm_servicebus_queue" "airq-telemetry" {
  name                         = "airq-telemetry"
  resource_group_name          = azurerm_resource_group.airq-rg.name
  namespace_name               = azurerm_servicebus_namespace.airq-bus.name
  max_size_in_megabytes        = 1024
  requires_duplicate_detection = false
  requires_session             = false
  max_delivery_count           = 10
  status                       = "Active"
  enable_partitioning          = false
  enable_express               = false
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace_authorization_rule
resource "azurerm_servicebus_namespace_authorization_rule" "airq-aut-sbn" {
  name                = "airq-aut-sbn"
  namespace_name      = azurerm_servicebus_namespace.airq-bus.name
  resource_group_name = azurerm_resource_group.airq-rg.name

  listen = true
  send   = true
  manage = true
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue_authorization_rule
resource "azurerm_servicebus_queue_authorization_rule" "airq-telemetry-rule" {
  name                = "airq-telemetry-rule"
  namespace_name      = azurerm_servicebus_namespace.airq-bus.name
  queue_name          = azurerm_servicebus_queue.airq-telemetry.name
  resource_group_name = azurerm_resource_group.airq-rg.name

  listen = true
  send   = true
  manage = true
}


# AZURE FUNCTION
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_plan
resource "azurerm_app_service_plan" "airq-sp" {
  name                         = "airq-sp"
  location                     = azurerm_resource_group.airq-rg.location
  resource_group_name          = azurerm_resource_group.airq-rg.name
  kind                         = "FunctionApp"
  reserved                     = true
  maximum_elastic_worker_count = 1
  sku {
    #tier = "Consumption"
    tier = "Dynamic"
    size = "Y1"
  }
  tags = {
    ApplicationName    = var.application_name
    Env                = var.environment
    Criticality        = "High"
    DataClassification = "Confidential"
    BusinessUnit       = var.business_unit
    Owner              = var.owner
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app
resource "azurerm_function_app" "airq-fun" {
  name                = "airq-fun2"
  location            = azurerm_resource_group.airq-rg.location
  resource_group_name = azurerm_resource_group.airq-rg.name
  app_service_plan_id = azurerm_app_service_plan.airq-sp.id
  app_settings = {
    AzureServiceBusConnectionString       = azurerm_servicebus_namespace_authorization_rule.airq-aut-sbn.primary_connection_string
    AzureCosmosDBConnectionString         = azurerm_cosmosdb_account.airq-cosmos.connection_strings[0]
    FUNCTIONS_WORKER_RUNTIME              = "python"
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.airq-fun.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.airq-fun.connection_string
    SCALE_CONTROLLER_LOGGING_ENABLED      = "AppInsights:Warning"
    WEBSITE_USE_PLACEHOLDER               = 0
    WEBSITE_MOUNT_ENABLED                 = 1
    ThingSpeakAPIKEY                      = var.ThingSpeakAPIKEY
    deviceToThingSpeak                    = var.deviceToThingSpeak
  }
  connection_string {
    name  = "AzureServiceBusConnectionString"
    type  = "ServiceBus"
    value = azurerm_servicebus_namespace_authorization_rule.airq-aut-sbn.primary_connection_string
  }
  storage_account_name       = azurerm_storage_account.airqst.name
  storage_account_access_key = azurerm_storage_account.airqst.primary_access_key
  daily_memory_time_quota    = 0
  enable_builtin_logging     = false
  https_only                 = false
  os_type                    = "linux"
  version                    = "~3"
  enabled                    = true
  site_config {
    always_on          = false
    min_tls_version    = 1.2
    ftps_state         = "AllAllowed"
    scm_ip_restriction = []
    linux_fx_version   = "PYTHON|3.9"
    cors {
      allowed_origins = [
        "https://functions.azure.com",
        "https://functions-staging.azure.com",
      "https://functions-next.azure.com"]
      support_credentials = false
    }
    use_32_bit_worker_process = false
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
      app_settings["AzureWebJobs.CosmosToThingSpeak.Disabled"], # prevent TF reporting configuration drift after app code is deployed
      app_settings["WEBSITE_RUN_FROM_PACKAGE"]
    ]
  }
}

# COSMOS DB
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account
resource "azurerm_cosmosdb_account" "airq-cosmos" {
  name                          = "airq-cosmos"
  location                      = azurerm_resource_group.airq-rg.location
  resource_group_name           = azurerm_resource_group.airq-rg.name
  offer_type                    = "Standard"
  kind                          = "GlobalDocumentDB"
  enable_free_tier              = true
  analytical_storage_enabled    = false
  public_network_access_enabled = true
  enable_automatic_failover     = false

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }

  geo_location {
    location          = azurerm_resource_group.airq-rg.location
    failover_priority = 0
  }
  tags = {
    ApplicationName    = var.application_name
    Env                = var.environment
    Criticality        = "High"
    DataClassification = "Confidential"
    BusinessUnit       = var.business_unit
    Owner              = var.owner
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_database
resource "azurerm_cosmosdb_sql_database" "airq-db" {
  name                = "airq-db"
  resource_group_name = azurerm_cosmosdb_account.airq-cosmos.resource_group_name
  account_name        = azurerm_cosmosdb_account.airq-cosmos.name
  throughput          = 400
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_container
resource "azurerm_cosmosdb_sql_container" "telemetry" {
  name                  = "telemetry"
  resource_group_name   = azurerm_cosmosdb_account.airq-cosmos.resource_group_name
  account_name          = azurerm_cosmosdb_account.airq-cosmos.name
  database_name         = azurerm_cosmosdb_sql_database.airq-db.name
  partition_key_path    = "/deviceid"
  partition_key_version = 2
  throughput            = 400
}

# Azure Insight
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights
resource "azurerm_application_insights" "airq-fun" {
  name                                  = "airq-fun"
  location                              = azurerm_resource_group.airq-rg.location
  resource_group_name                   = azurerm_resource_group.airq-rg.name
  application_type                      = "web"
  retention_in_days                     = 90
  daily_data_cap_in_gb                  = 10
  daily_data_cap_notifications_disabled = false
  sampling_percentage                   = 100
  tags = {
    ApplicationName    = var.application_name
    Env                = var.environment
    Criticality        = "High"
    DataClassification = "Confidential"
    BusinessUnit       = var.business_unit
    Owner              = var.owner
  }
}
