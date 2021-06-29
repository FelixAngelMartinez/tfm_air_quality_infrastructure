# Project: Intelligent system for monitoring indoor air quality and fight against COVID-19
# Version: 1.0
# Author: Felix Angel Martinez Muela
# https://github.com/terraform-providers/terraform-provider-azurerm


/*

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
resource "azurerm_kubernetes_cluster" "ariq-kc" {
  name                = "ariqkc"
  location            = azurerm_resource_group.airq-rg.location
  resource_group_name = azurerm_resource_group.airq-rg.name
  dns_prefix          = "ariqkc"
  kubernetes_version = "1.21.1"
  #node_resource_group = azurerm_resource_group.airq-grp-kc.name
  sku_tier = "Free"
  default_node_pool {
    name       = "airqdnp"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

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
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.ariq-kc.kube_config.0.client_certificate
  description = "Client certificate"
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.ariq-kc.kube_config_raw
  description = "Kube config"
  sensitive = true
}
*/