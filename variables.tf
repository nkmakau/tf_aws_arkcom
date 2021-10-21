provider "aws" {
  region  = var.aws_region
  profile = "uat" //Change this to your AWS CLI profile
}

variable "region" {
  description = "Region Name"
  default     = "eu-west-1"
}

variable "aws_region" {
  description = "EC2 Region for the VPC"
  default     = "eu-west-1"
}

variable "remote_cidr" {
  description = "CIDR from Remote Testing Source"
  default     = "102.68.141.230/32" //Change this to the public IP of your ISP
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_2a_cidr" {
  description = "CIDR for the public 2a Subnet"
  default     = "10.0.0.0/25"
}

variable "public_subnet_2b_cidr" {
  description = "CIDR for the public 2b Subnet"
  default     = "10.0.0.128/25"
}

variable "private_subnet_2a_cidr" {
  description = "CIDR for the private 2a Subnet"
  default     = "10.0.1.0/25"
}

variable "private_subnet_2b_cidr" {
  description = "CIDR for the private 2b Subnet"
  default     = "10.0.1.128/25"
}

variable "private_db_subnet_2a_cidr" {
  description = "CIDR for the private 2a Subnet"
  default     = "10.0.2.0/25"
}

variable "private_db_subnet_2b_cidr" {
  description = "CIDR for the private 2b Subnet"
  default     = "10.0.2.128/25"
}

variable "key_path" {
  description = "SSH Public Key Path"
  default     = "/users/nosh/.ssh/id_ed25519.pub" //Change this to a valid ssh key on your local machine
}

variable "asg_jenkins_slave_min" {
  description = "Auto Scaling Minimum Size"
  default     = "1"
}

variable "asg_jenkins_slave_max" {
  description = "Auto Scaling Maximum Size"
  default     = "2"
}

variable "asg_jenkins_slave_desired" {
  description = "Auto Scaling Desired Size"
  default     = "2"
}

variable "asg_jenkins_master_min" {
  description = "Auto Scaling Minimum Size"
  default     = "1"
}

variable "asg_jenkins_master_max" {
  description = "Auto Scaling Maximum Size"
  default     = "1"
}

variable "asg_jenkins_master_desired" {
  description = "Auto Scaling Desired Size"
  default     = "1"
}

variable "asg_git_min" {
  description = "Auto Scaling Minimum Size"
  default     = "1"
}

variable "asg_git_max" {
  description = "Auto Scaling Maximum Size"
  default     = "2"
}

variable "asg_git_desired" {
  description = "Auto Scaling Desired Size"
  default     = "1"
}

variable "data_volume_type" {
  description = "EBS Volume Type"
  default     = "gp2"
}

variable "data_volume_size" {
  description = "EBS Volume Size"
  default     = "50"
}

variable "root_block_device_size" {
  description = "Root EBS Volume Size"
  default     = "50"
}

variable "gitlab_postgresql_password" {
  default = "supersecret"
}

variable "git_rds_multiAZ" {
  default = "false"
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1c"]
}