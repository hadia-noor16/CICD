variable "dev_bucket" {
  description = "This is the name of the development bucket"
  type        = string
  default     = "hadiadev.123"
}

variable "pro_bucket" {
  description = "This is the name of the production bucket"
  type        = string
  default     = "hadiaprod.123"
}

variable "artifact_bucket" {
  description = "This is the name of artifact bucket"
  type        = string
  default     = "hn-artifact-123"
}

variable "aws_region" {
  description = "The AWS region my website is deployed"
  type        = string
  default     = "us-east-1"
}

variable "github_connector" {
  type= string
}

variable "domain_name" {
  type= string
  default= "mydevopslife.com."
}

variable "zone_id" {
  type= string
}

variable "certificate_arn"{
  type=string
}

variable "approval_email" {
  type= string
  default = "hadianoor16@gmail.com"
}