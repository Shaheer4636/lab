provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "windows_server" {
  ami                    = "ami-070f90bab72874c6f"
  instance_type          = "t2.large"
  subnet_id              = "subnet-379e115c"
  vpc_security_group_ids = ["sg-0101e8fd37928991e"]
  iam_instance_profile   = "AmazonSSMRoleForInstancesQuickSetup"
  key_name               = "lm-related-tee"  # Replace with your EC2 key pair if using RDP

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
    Name = "Astadia-TEE"
  }
}
