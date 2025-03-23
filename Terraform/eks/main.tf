provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}


terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-03096174636"  # Replace with your bucket name
    key            = "terraform/state.tfstate"    # Path inside the S3 bucket
    region         = "us-east-1"                  # Change if needed
    encrypt        = true                         # Encrypt state file
    dynamodb_table = "terraform-lock"             # Enable state locking
  }
}

# Define environment-specific instance types
variable "instance_type" {
  default = {
    default  = "t2.micro"
    dev      = "t2.micro"
    staging  = "t3.small"
    prod     = "t3.medium"
  }
}

# Create EC2 instance based on the current workspace
resource "aws_instance" "example" {
  ami           = "ami-05b10e08d247fb927"
  instance_type = lookup(var.instance_type, terraform.workspace, "t2.micro")

  tags = {
    Name = "MyInstance-${terraform.workspace}"
  }
}