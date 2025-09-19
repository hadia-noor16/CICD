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

variable "aws_region" {
  description = "This is the main region where the resources for HealthCare North will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "github_connector" {
  type= string
}