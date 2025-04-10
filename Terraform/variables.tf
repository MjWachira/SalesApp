variable "subscription_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type = string
}

variable "tenant_id" {
  type = string
}
variable "rg_prefix" {
  description = "The prefix for the resource group"
  type        = string
}

variable "project_prefix" {
  description = "The prefix for the project"
  type        = string
}
variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = { environment = "dev" }
}
variable "location" {
  description = "Default Azure region for resource deployment"
  type        = string
  default     = "West US"
}
variable "azure_devops_url" {
  description = "Azure DevOps organization URL"
  type        = string
  default     = "https://dev.azure.com/SalesAppOrg"
}

variable "azure_devops_pat" {
  description = "Azure DevOps Personal Access Token with Agent Pool permissions"
  type        = string
  default     = "3l1LrEZw2GhiQQq8TmvlGYSIW0JRBPBsUy2dEmqoh5njjWMAwLyMJQQJ99BDACAAAAAAAAAAAAASAZDO4IeL"

}

variable "azure_devops_pool" {
  description = "Azure DevOps Agent Pool name"
  type        = string
  default     = "MyWindowsPool"
}