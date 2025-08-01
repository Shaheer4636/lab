# Enable multiple simultaneous RDP sessions
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name 'fSingleSessionPerUser' -Value 0

# Optional: Increase max concurrent RDP connections (uncomment if needed)
# Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'MaxInstanceCount' -Value 10

# Create Users with Passwords
net user user1 "UserP@ssw0rd1!" /add
net user user2 "UserP@ssw0rd2!" /add
net user user3 "UserP@ssw0rd3!" /add

# Add users to Remote Desktop Users group
net localgroup "Remote Desktop Users" user1 /add
net localgroup "Remote Desktop Users" user2 /add
net localgroup "Remote Desktop Users" user3 /add
