provider "aws" {
  region = "ap-northeast-1"
}
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "my-vpc"
  cidr = "192.168.0.0/16"
  azs             = ["ap-northeast-1a","ap-northeast-1c"]
  public_subnets  = ["192.168.1.0/24","192.168.2.0/24"]
  enable_nat_gateway = false
  enable_vpn_gateway = false
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_tls"
  }
}
resource "aws_key_pair" "deployer" {
  key_name   = "bablookey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDWu1zHMgZKHtHy9amrBAOji0iBC0UhHeOPZ2DA9andnzc12d3FUcaewQQtBMdawC5spnS22LRtlBnTiYfLHpZcFrRlKQpSlQbMT3T4QxI6gTJ6YomkeAH0Iqh38wbOa9UegWq5sVrrqnaUahcudznEMiyaCEw6iR1p8XtshWG4WwMzW6PbqK16CoOeMz5c7WjIAjhuTMrcFBCXG4d4FW3wzAEPhvU2vNHMHdTXnrCxBPr8e+FTyTBYEc1BmXSalx9siyVr5KVym++xwwGUyQFx1aLl4E5fR+Qk7YI7uz5JN9+J5Te66NZti9U7OwVGTRnJiXn1WTWHoJQgYNgsAiBdjy5/N6sCqZKn6XitT6BayqbpMiPi+yMuVve0C2XkMHQH0qDekA0p4SM5+f7nU07zyUB2RkqaKiE4Z5ptMxx5Ffd1B5+ystHsGxsX8XB5LH8ZpYTDz0zLLGM2iHvOOO5P8HE5Z+sPkeI/Dx3xYPcjnoDcx9e3+2w7Ne19qJZkNPM= kiran teja@LAPTOP-6T3QPJBC"
}
resource "aws_instance" "main" {
  ami                     = "ami-0b828c1c5ac3f13ee"
  instance_type           = "t3.small"
  key_name = "bablookey"
  associate_public_ip_address = true
  security_groups = [ "${aws_security_group.allow_tls.id}" ]
  subnet_id = module.vpc.public_subnets[0]
    tags = {
      "Name" = "main"
}
}

