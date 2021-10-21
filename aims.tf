# Define the RHEL 7.2 AMI by:
# Redhat, Latest, x86_64,ELB,HVM, RHEL 7.5
data "aws_ami" "rhel" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }
}

data "aws_ami" "amzn" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }
}