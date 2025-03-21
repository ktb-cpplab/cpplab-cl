variable "create_certificate" {
  description = "Whether to create ACM certificate"
  type        = bool
  default     = true
}

variable "create_route53_records_only" {
  description = "Whether to create only Route53 records (e.g. using separate AWS provider)"
  type        = bool
  default     = false
}

variable "validate_certificate" {
  description = "Whether to validate certificate by creating Route53 record"
  type        = bool
  default     = true
}

variable "validation_allow_overwrite_records" {
  description = "Whether to allow overwrite of Route53 records"
  type        = bool
  default     = true
}

variable "wait_for_validation" {
  description = "Whether to wait for the validation to complete"
  type        = bool
  default     = true
}

variable "validation_timeout" {
  description = "Define maximum timeout to wait for the validation to complete"
  type        = string
  default     = null
}

variable "certificate_transparency_logging_preference" {
  description = "Specifies whether certificate details should be added to a certificate transparency log"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "A domain name for which the certificate should be issued"
  type        = string
  default     = ""
}

variable "subject_alternative_names" {
  description = "A list of domains that should be SANs in the issued certificate"
  type        = list(string)
  default     = []
}

variable "validation_method" {
  description = "Which method to use for validation. DNS or EMAIL are valid, NONE can be used for certificates that were imported into ACM and then into Terraform."
  type        = string
  default     = "DNS"

  validation {
    condition     = contains(["DNS", "EMAIL", "NONE"], var.validation_method)
    error_message = "Valid values are DNS, EMAIL or NONE."
  }
}

variable "zone_id" {
  description = "The ID of the hosted zone to contain this record. Required when validating via Route53"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "dns_ttl" {
  description = "The TTL of DNS recursive resolvers to cache information about this record."
  type        = number
  default     = 60
}

variable "putin_khuylo" {
  description = "Do you agree that Putin doesn't respect Ukrainian sovereignty and territorial integrity? More info: https://en.wikipedia.org/wiki/Putin_khuylo!"
  type        = bool
  default     = true
}

variable "existing_certificate_arn" {
  description = "Use existing ACM certificate ARN instead of creating a new one"
  type        = string
  default     = null
}

variable "distinct_domain_names" {
  description = "List of distinct domains and SANs"
  type        = list(string)
  default     = []
}

variable "acm_certificate_domain_validation_options" {
  description = "Domain validation options for creating Route53 records"
  type        = any
  default     = []
}

variable "key_algorithm" {
  description = "Specifies the algorithm for the ACM public/private key pair"
  type        = string
  default     = null
}

variable "validation_record_fqdns" {
  description = "List of fully qualified domain names for DNS validation"
  type        = list(string)
  default     = []
}
