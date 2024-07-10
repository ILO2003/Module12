resource "aws_subnet" "myapp-subnet-1-ilo" {
    vpc_id = var.vpc_id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
      Name: "${var.env_prefix}-subnet-1-ilo"
    }
}

resource "aws_internet_gateway" "myapp-igw-ilo"{
    vpc_id = var.vpc_id
    tags = {
        Name: "${var.env_prefix}-igw-ilo"
    }
}

resource "aws_route_table" "myapp-route-table-ilo"{
    vpc_id = var.vpc_id

    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw-ilo.id
    }
    tags = {
        Name: "${var.env_prefix}-rtb-ilo"
    }
}
