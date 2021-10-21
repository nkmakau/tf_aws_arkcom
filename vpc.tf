# Define our VPC
resource "aws_vpc" "acme" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name          = "acme VPC"
    BusinessOwner = "DevSecOps"
    CreatedBy     = "Noah Makau"
  }
}