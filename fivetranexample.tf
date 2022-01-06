provider "aws" {
    region = "ap-south-1"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}
variable public_key_location {}


#  Create A VPC
resource "aws_vpc" "Him-VPC1" {
  cidr_block       =  var.vpc_cidr_block

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}
#  Create a Subnet
resource "aws_subnet" "Him-Subnet1" {
  vpc_id     = aws_vpc.Him-VPC1.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone

  tags = {
    Name = "${var.env_prefix}-Subnet-1"
  }
}

#  Create a ROUTE TABLE

resource "aws_route_table" "My-app-ROUTE-Table" {
  vpc_id = aws_vpc.Him-VPC1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-app-IGW.id
  }
    tags = {
    Name = "${var.env_prefix}-Route-Table1"
  
  }
  

}

#  Create a INTERNET GATEWAY
resource "aws_internet_gateway" "my-app-IGW" {
  vpc_id = aws_vpc.Him-VPC1.id
  tags = {
    Name = "${var.env_prefix}-igw-1"
  }


}

#  Create a Subnet Association in Route Table

resource "aws_route_table_association" "Subnet-association" {
  subnet_id      = aws_subnet.Him-Subnet1.id
  route_table_id = aws_route_table.My-app-ROUTE-Table.id
}


#  Create a Security Group

resource "aws_security_group" "My-apps-Security-Group" {
  name        = "Myapp-SG"
  vpc_id      = aws_vpc.Him-VPC1.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip]
  }

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_prefix}-sg1"
  }
}

data "aws_ami" "latest-amazone-image" {
  most_recent =  true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }


}

resource "aws_key_pair" "ssh-key" {
  key_name = "server-key"
  public_key = "${file(var.public_key_location)}"
  
}

resource "aws_instance" "Dev-instance" {
  ami           = data.aws_ami.latest-amazone-image.id
  instance_type = "t2.micro"
  availability_zone = var.avail_zone

  subnet_id = aws_subnet.Him-Subnet1.id
  vpc_security_group_ids = [aws_security_group.My-apps-Security-Group.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  tags = {
    Name = "${var.env_prefix}-dev-server"
  }
}

# To Run all commands in Servers

user_data = <<EOF
               #!/bin/bash
               sudo yum update -y &&  sudo yum install -y docker
               sudo systemctl start docker
               sudo usermod -aG docker ec2-user
               docker run -p 8080:80 nginx


          EOF

output "aws_ami_id" {
  value = data.aws_ami.latest-amazone-image.id
  
}