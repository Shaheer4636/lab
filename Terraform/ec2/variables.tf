variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "ami_name" {
  default = "amzn2-ami-hvm-*-x86_64-gp2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "volume_size" {
  default = 20
}

variable "instance_profile_name" {
  default = "ec2-ssm-role"
}
