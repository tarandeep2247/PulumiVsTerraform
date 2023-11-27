provider "aws" {
  region = "eu-west-2" 
}

// Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main"
  }
}

// Create a Subnet
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "main"
  }
}

// Create an EC2 instance
resource "aws_instance" "web-server-instance" {
  ami           = "ami-0cfd0973db26b893b"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id
  tags = {
    Name = "web-server-instance"
  }
}

// Create an RDS Mysql instance
resource "aws_db_instance" "db-instance" {
  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t2.micro"
  db_name           = "db_instance"
  username          = "admin_user"
  password          = "admin_password"
  allocated_storage = 10
  skip_final_snapshot = true
  publicly_accessible = true

  vpc_security_group_ids = []

  tags = {
    Name = "db-instance"
  }
//  subnet_group_name = "main"
}

// Create an IAM Role
resource "aws_iam_role" "app-layer-role" {
  name = "app-layer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

// Output the IDs of the created resources
output "webserver_id" {
  value = aws_instance.web-server-instance.id
}

output "db_id" {
  value = aws_db_instance.db-instance.id
}

output "role_id" {
  value = aws_iam_role.app-layer-role.id
}

