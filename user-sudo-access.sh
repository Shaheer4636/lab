# PowerShell script to install AWS SSM Agent on Windows Server (us-east-1)

# Step 1: Download SSM Agent installer
$ssmUrl = "https://s3.amazonaws.com/amazon-ssm-us-east-1/latest/windows_amd64/AmazonSSMAgentSetup.exe"
$installerPath = "$env:USERPROFILE\Downloads\AmazonSSMAgentSetup.exe"
Invoke-WebRequest -Uri $ssmUrl -OutFile $installerPath

# Step 2: Install SSM Agent silently
Start-Process -FilePath $installerPath -ArgumentList "/quiet" -Wait

# Step 3: Start the SSM Agent service
Start-Service AmazonSSMAgent

# Step 4: Set the service to start automatically
Set-Service -Name AmazonSSMAgent -StartupType Automatic

# Step 5: Confirm service is running
Get-Service AmazonSSMAgent
