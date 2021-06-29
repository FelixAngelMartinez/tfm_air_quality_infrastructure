# Project: Intelligent system for monitoring indoor air quality and fight against COVID-19
# Version: 1.0
# Author: Felix Angel Martinez Muela
# https://github.com/terraform-providers/terraform-provider-azurerm

variable "application_name" {
  description = "Application name"
  type        = string
  default = ""
}

variable "environment" {
  description = "Working environment"
  type        = string
  default = ""
}

variable "business_unit" {
  description = "Business Unit"
  type        = string
  default = ""
}

variable "owner" {
  description = "Owner of the asset"
  type        = string
  default = ""
}

variable "subscription_id" {
  description = "subscription_id"
  type        = string
  default = ""
}
variable "tenant_id" {
  description = "tenant_id"
  type        = string
  default = ""
}

variable "tenant" {
  description = "tenant"
  type        = string
  default = ""
}

variable "ThingSpeakAPIKEY" {
  description = "ThingSpeakAPIKEY"
  type        = string
  default = ""
}

variable "deviceToThingSpeak" {
  description = "deviceToThingSpeak"
  type        = string
  default = ""
}
