variable "parameter_name" {
  description = "Name of the parameter to retrieve from Parameter Store"
  type        = string
}

variable "new_value" {
  description = "The new value to set in Parameter Store"
  type        = string
}