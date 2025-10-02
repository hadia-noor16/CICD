variable "dev_bucket" {
  description = "This is the name of the development bucket for HealthCare North"
  type        = string
  default     = "hadiadev.123"
}

variable "pro_bucket" {
  description = "This is the name of the production bucket for HealthCare North"
  type        = string
  default     = "hadiaprod.123"
}

variable "artifact_bucket" {
  description = "This is the name of the production bucket for HealthCare North"
  type        = string
  default     = "hn-artifacts123"
}

variable "aws_region" {
  description = "This is the main region where the resources for HealthCare North will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "github_connector" {
  type= string
}

variable "approval_email" {
  description = "Email to notify for manual approvals"
  type        = string
}

variable "domain_name" {
  type= string
  default= "mydevopslife.com."
}

variable "zone_id" {
  type= string
}