variable "zone_id" {
  description = "ID of the existing DNS zone"
  type        = string
}

variable "zone_name" {
  description = "Name of the Route 53 hosted zone"
  type        = string
  default     = null
}

variable "records" {
  description = "List of objects of DNS records"
  type        = any
  default     = []
}

variable "records_jsonencoded" {
  description = "List of map of DNS records (stored as jsonencoded string, for terragrunt)"
  type        = string
  default     = null
}
