# Define the public subnets
resource "aws_subnet" "public-subnet1" {
  vpc_id            = aws_vpc.acme.id
  cidr_block        = var.public_subnet_2a_cidr
  availability_zone = "eu-west-1a"

  tags = {
    Name          = "Web Public Subnet 1"
    BusinessOwner = "DevSecOps"
    CreatedBy     = "Noah Makau"
  }
}

resource "aws_subnet" "public-subnet2" {
  vpc_id            = aws_vpc.acme.id
  cidr_block        = var.public_subnet_2b_cidr
  availability_zone = "eu-west-1c"

  tags = {
    Name          = "Web Public Subnet 2"
    BusinessOwner = "DevSecOps"
    CreatedBy     = "Noah Makau"
  }
}

# Define the private subnets
resource "aws_subnet" "private-subnet1" {
  vpc_id            = aws_vpc.acme.id
  cidr_block        = var.private_subnet_2a_cidr
  availability_zone = "eu-west-1a"

  tags = {
    Name          = "App Private Subnet 1"
    BusinessOwner = "DevSecOps"
    CreatedBy     = "Noah Makau"
  }
}

resource "aws_subnet" "private-subnet2" {
  vpc_id            = aws_vpc.acme.id
  cidr_block        = var.private_subnet_2b_cidr
  availability_zone = "eu-west-1c"

  tags = {
    Name          = "App Private Subnet 2"
    BusinessOwner = "DevSecOps"
    CreatedBy     = "Noah Makau"
  }
}

# Define the DB subnets
resource "aws_subnet" "private-db-subnet1" {
  vpc_id            = aws_vpc.acme.id
  cidr_block        = var.private_db_subnet_2a_cidr
  availability_zone = "eu-west-1a"

  tags = {
    Name          = "Database Private Subnet 1"
    BusinessOwner = "DevSecOps"
    CreatedBy     = "Noah Makau"
  }
}

resource "aws_subnet" "private-db-subnet2" {
  vpc_id            = aws_vpc.acme.id
  cidr_block        = var.private_db_subnet_2b_cidr
  availability_zone = "eu-west-1c"

  tags = {
    Name          = "Database Private Subnet 2"
    BusinessOwner = "DevSecOps"
    CreatedBy     = "Noah Makau"
  }
}

#Define DB Subnet Group
resource "aws_db_subnet_group" "default" {
  name       = "main-subnet-group"
  subnet_ids = ["${aws_subnet.private-db-subnet1.id}", "${aws_subnet.private-db-subnet2.id}"]

  tags = {
    Name          = "DB Subnet Group"
    BusinessOwner = "DevSecOps"
    CreatedBy     = "Noah Makau"
  }
}