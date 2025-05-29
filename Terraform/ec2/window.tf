provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "windows_server" {
  ami                    = "ami-070f90bab72874c6f"
  instance_type          = "t2.large"  # You can change to your desired instance type
  subnet_id              = "subnet-379e115c"
  vpc_security_group_ids = ["sg-0101e8fd37928991e"]
  iam_instance_profile   = "AmazonSSMRoleForInstancesQuickSetup"
  key_name               = "lm-related-tee" 
  tags = {
    Name = "WindowsServer"
  }
}
