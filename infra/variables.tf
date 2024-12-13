variable "location" {
  description = "The supported Azure location where the resource deployed"
  default     = "australiaeast"
  type        = string
}

variable "environment_name" {
  description = "The name of the azd environment to be deployed"
  type        = string
}

variable "principal_id" {
  description = "The Id of the azd service principal to add to deployed keyvault access policies"
  type        = string
  default     = ""
}

variable "sql_login" {
  description = "The login id for the sql server"
  type        = string
  default     = ""
}

variable "sql_password" {
  description = "The password for the sql server"
  type        = string
  default     = ""
}