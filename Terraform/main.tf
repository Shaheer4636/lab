

# main.tf
resource "aws_vpc" "ak_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "ak-vpc" }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.ak_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = { Name = "ak-public-subnet" }
}

# Private subnets in 3 AZs
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.ak_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "ak-private-subnet-1" }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.ak_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  tags = { Name = "ak-private-subnet-2" }
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id            = aws_vpc.ak_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1c"
  tags = { Name = "ak-private-subnet-3" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.ak_vpc.id
  tags = { Name = "ak-gw" }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = { Name = "ak-natgw" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ak_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "ak-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.ak_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }
  tags = { Name = "ak-private-rt" }
}

# Associate all private subnets
resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc_3" {
  subnet_id      = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.private_rt.id
}

# Security Groups
resource "aws_security_group" "bastion_sg" {
  name   = "ak-bastion-sg"
  vpc_id = aws_vpc.ak_vpc.id
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

resource "aws_security_group" "ec2_sg" {
  name   = "ak-ec2-sg"
  vpc_id = aws_vpc.ak_vpc.id
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name   = "ak-rds-sg"
  vpc_id = aws_vpc.ak_vpc.id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ak-ssm-profile-1"
  role = "AmazonSSMRoleForInstancesQuickSetup"
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  key_name                    = "ak"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  tags = { Name = "ak-bastion" }
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.private_subnet_1.id
  key_name                    = "ak"
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  root_block_device {
    volume_size = 40
    volume_type = "gp2"
  }
  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y postgresql postgresql-contrib
              systemctl enable postgresql
              systemctl start postgresql
              EOF
  tags = { Name = "ak-ec2-private" }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "ak-rds-subnet-group"
  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id,
    aws_subnet.private_subnet_3.id
  ]
  tags = { Name = "ak-rds-subnet-group" }
}

resource "aws_db_instance" "rds" {
  identifier              = "ak-postgres"
  engine                  = "postgres"
  engine_version          = "16.5"
  instance_class          = "db.t3.medium"
  allocated_storage       = 20
  db_name                 = "akdb"
  username                = "akadmin"
  password                = "SecurePassw0rd!"
  publicly_accessible     = false
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot     = true
  tags = { Name = "ak-rds" }
}
