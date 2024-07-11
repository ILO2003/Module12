provider "aws" {
    region = "eu-north-1"
}

resource "aws_vpc" "myapp-vpc-ilo" {
    cidr_block = var.vpc_cidr_block
    tags = {
      Name: "${var.env_prefix}-vpc-ilo"
    }
}

module "myapp-subnet-ilo" {
    source = "./modules/subnet"
    subnet_cidr_block = var.subnet_cidr_block
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
    vpc_id = aws_vpc.myapp-vpc-ilo.id
    subnet_id = module.myapp-subnet-ilo.subnet.id
    route_table_id = module.myapp-subnet-ilo.rtb.id
}

module "myapp-server" {
    source = "./modules/webserver"
    vpc_id = aws_vpc.myapp-vpc-ilo.id
    my_ip = var.my_ip
    env_prefix = var.env_prefix
    image_name = var.image_name
    public_key = var.public_key
    instance_type = var.instance_type
    subnet_id = module.myapp-subnet-ilo.subnet.id
    avail_zone = var.avail_zone
}


