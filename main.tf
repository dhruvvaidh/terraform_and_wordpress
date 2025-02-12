# Dhruv Vaidh dv8292@g.rit.edu
# Defining the Security groups to allow http ssh inbound traffic
resource "aws_security_group" "web_sg" {
  name        = "allow_http_ssh"
  description = "Allow HTTP and SSH inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"  # Set AWS region to US East 1 (N. Virginia)
}

# Local variables block for configuration values
locals {
    aws_key = "dhruvvaidh-iam-key"   # SSH key pair name for EC2 instance access
}

# EC2 instance resource definition
resource "aws_instance" "my_server" {
   ami           = data.aws_ami.amazonlinux.id  # Use the AMI ID from the data source
   instance_type = var.instance_type            # Use the instance type from variables
   key_name      = "${local.aws_key}"          # Specify the SSH key pair name
   vpc_security_group_ids = [aws_security_group.web_sg.id]  # Associate the security group
   
   user_data = file("wp_install.sh") # Run WordPress install script automatically on instance launch
  
   # Add tags to the EC2 instance for identification
   tags = {
     Name = "my ec2"
   }                  
}

# Output the Public IP
output "public_ip" {
  value = aws_instance.my_server.public_ip
}

terraform {
  backend "s3" {
    bucket         = "terraform-dv"  # Replace with your actual bucket name
    key            = "terraform/state.tfstate"   # Path inside the bucket
    region         = "us-east-1"                 # Replace with your AWS region
    encrypt        = true                         # Encrypts the state file
  }
}