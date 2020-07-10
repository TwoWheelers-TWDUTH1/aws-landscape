variable "deployment_identifier" {
  description = "An identifier for this instantiation."
}

variable "vpc_id" {
  description = "VPC in which to provision Kafka"
}

variable "client_subnets"  {
  description = "List of subnet in which to provision Kafka"
  type = "list"
}

variable "cohort" {
  description = "Training cohort, eg: london-summer-2018"
}

variable "aws_region" {
  description = "Region in which to build resources."
}

variable "instance_type" {
  description = "Instance type for the msk cluster"
  type = "string"
}
