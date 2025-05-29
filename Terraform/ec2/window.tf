provider "aws" {
  region = "us-east-2"
}

# Security Group
resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "Allow all inbound and outbound traffic"
  vpc_id      = "vpc-5717703c"

  ingress {
    description = "Allow all inbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name     = "public_sg"
    os       = "windows 2025"
    request  = "AK"
    usefor   = "testing window software"
  }
}

# Windows Server EC2 Instance
resource "aws_instance" "windows_server" {
  ami                    = "ami-070f90bab72874c6f"
  instance_type          = "t3.large"
  subnet_id              = "subnet-379e115c"
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  iam_instance_profile   = "AmazonSSMRoleForInstancesQuickSetup"
  key_name               = "lm-related-tee"  # Replace with your actual key name

  user_data = <<-EOF
    <powershell>
    try {
      $chromeUrl = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
      $installerPath = "$env:TEMP\\chrome_installer.exe"

      Invoke-WebRequest -Uri $chromeUrl -OutFile $installerPath -UseBasicParsing
      Start-Process -FilePath $installerPath -ArgumentList "/silent /install" -Wait
      Remove-Item $installerPath -Force
      Write-Output "Google Chrome installed successfully."
    } catch {
      Write-Error "Failed to install Chrome: $_"
    }
    </powershell>
  EOF

  tags = {
    Name     = "WindowsServer-ChromeReady"
    os       = "windows 2025"
    request  = "AK"
    usefor   = "testing window software"
  }
}
