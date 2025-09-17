variable "dev_bucket" {
  description = "This is the name of the development bucket for HealthCare North"
  type        = string
  default     = "<hcn-dev-bucket-name>"
}

variable "pro_bucket" {
  description = "This is the name of the production bucket for HealthCare North"
  type        = string
  default     = "<hcn-prod-bucket-name>"
}

variable "aws_region" {
  description = "This is the main region where the resources for HealthCare North will be deployed"
  type        = string
  default     = "<default-aws-region>"
}