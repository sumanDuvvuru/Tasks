# Define variables for Azure Container Registry

variable "rgname" {
  description = "The name of the resource group"
  type = string
}
variable "rglocation" {
  description = "The name of the resource group location"
  type = string
}
variable "container_registry_name" {
  description = "the name of the Azure Container Registry"
  type = string
  
}
variable "registry_sku" {
  description   = "The SKU (pricing tier) of the Azure Container Registry."
  type          = string

}
variable "admin_enabled" {
  type        = bool
}
variable "georeplication_locations" {
  description = "List of additional locations for geo-replication of the Azure Container Registry."
  type        = list(string)
}