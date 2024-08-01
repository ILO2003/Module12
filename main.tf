provider "aws" {
    region = "eu-north-1"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip{}
variable instance_type{}
variable image_name{}
variable public_key_location{}
variable ssh_key_private{}

resource "aws_vpc" "myapp-vpc-ilo" {
    cidr_block = var.vpc_cidr_block
    tags = {
      Name: "${var.env_prefix}-vpc-ilo"
    }
}

resource "aws_subnet" "myapp-subnet-1-ilo" {
    vpc_id = aws_vpc.myapp-vpc-ilo.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
      Name: "${var.env_prefix}-subnet-1-ilo"
    }
}

resource "aws_internet_gateway" "myapp-igw-ilo"{
    vpc_id = aws_vpc.myapp-vpc-ilo.id
    tags = {
        Name: "${var.env_prefix}-igw-ilo"
    }
}

resource "aws_route_table" "myapp-route-table-ilo"{
    vpc_id = aws_vpc.myapp-vpc-ilo.id

    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw-ilo.id
    }
    tags = {
        Name: "${var.env_prefix}-rtb-ilo"
    }
}

resource "aws_route_table_association" "a-rtb-subnet-ilo"{
    subnet_id = aws_subnet.myapp-subnet-1-ilo.id
    route_table_id = aws_route_table.myapp-route-table-ilo.id
}

resource "aws_security_group" "myapp-sg-ilo"{
    name = "myapp-sg-ilo"
    vpc_id = aws_vpc.myapp-vpc-ilo.id

    ingress{
        from_port = 22
        to_port = 22
        protocol = "TCP"
        cidr_blocks = [var.my_ip]
    }

    ingress{
        from_port = 8080
        to_port = 8080
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name: "${var.env_prefix}-sg-ilo"
    }
}
data "aws_ami" "latest-amazon-linux-image"{
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["al2023-ami-*-kernel-*-x86_64"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_key_pair" "ssh-key"{
    key_name = "server-key"
    public_key = file(var.public_key_location)
}

resource "aws_instance" "myapp-server-ilo"{
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.myapp-subnet-1-ilo.id
    vpc_security_group_ids = [aws_security_group.myapp-sg-ilo.id]
    availability_zone = var.avail_zone
    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name

    tags = {
        Name: "${var.env_prefix}-server"
    }

    provisioner "local-exec"{
        working_dir = "/Users/ilo/Desktop/DevOps/ansible"
        command = "ansible-playbook --inventory ${self.public_ip}, --private-key ${var.ssh_key_private} --user ec2-user deploy-docker.yaml"
    }
}

/*  Configure provisioner using null_resource with triggering to have seperate task for ansible task execution
    triggers = {
        trigger = aws_instance.myapp-server-ilo.public_ip
    }
    
    provisioner "local-exec"{
        working_dir = "/Users/ilo/Desktop/DevOps/ansible"
        command = "ansible-playbook --inventory ${aws_instance.myapp-server-ilo.public_ip}, --private-key ${var.ssh_key_private} --user ec2-user deploy-docker.yaml"
    }
*/

output "ec2_public_ip"{
    value = aws_instance.myapp-server-ilo.public_ip
}