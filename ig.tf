# Define the internet gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.acme.id

  tags = {
    Name          = "Acme IGW"
    BusinessOwner = "DevSecOps"
    CreatedBy     = "Noah Makau"
  }
}