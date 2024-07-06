provider "aws" {
    region = "eu-north-1"
}

resource "aws_vpc" "development-vpc-ilo" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name: "development",
      vpc_env: "dev"
    }
}

resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.development-vpc-ilo.id
    cidr_block = "10.0.15.0/24"
    availability_zone = "eu-north-1a"
    tags = {
      Name: "subnet-1-dev"
    }
}

data "aws_vpc" "existing_vpc" {
    default = true
}

resource "aws_subnet" "dev-subnet-2" {
    vpc_id = data.aws_vpc.existing_vpc.id
    cidr_block = "172.31.48.0/20"
    availability_zone = "eu-north-1a"
    tags = {
      Name: "subnet-2-default"
    }
}