provider "aws" {
    region = "ap-south-1"
    access_key = "AKIAXS5VW6GFKQGUDCWN"
    secret_key = "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"
}


variable "subnet_cidr_block" {
  description = "subnet cidr block"
  
}

variable "VPC_cidr_BLOCK" {
  description = "VPC cidr block"
  
}

#  Create A VPC
resource "aws_vpc" "Him-VPC1" {
  cidr_block       =  var.VPC_cidr_BLOCK

  tags = {
    Name = "HimVPC1"
  }
}

#  Create a Subnet

resource "aws_subnet" "Him-Subnet1" {
  vpc_id     = aws_vpc.Him-VPC1.id
  cidr_block = var.subnet_cidr_block
  availability_zone = "ap-south-1b"

  tags = {
    Name = "HimSubnet1"
  }
}
