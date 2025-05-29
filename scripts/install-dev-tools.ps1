Write-Host "Installing OS software via Chocolatey..."

# Install Chocolatey
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression

# Ensure Chocolatey is available
$env:Path += ";$env:ALLUSERSPROFILE\chocolatey\bin"

# List of packages to install
$packages = @(
    "docker-desktop",       # Docker
    "openjdk",              # OpenJDK 21 (defaults to latest openjdk)
    "strawberryperl",       # Strawberry Perl
    "python311",            # Python 3.11
    "notepadplusplus.install", # Notepad++
    "7zip.install",         # 7-Zip
    "dbeaver",              # DBeaver
    "filezilla",            # FileZilla
    "araxis-merge",         # Araxis Merge
    "vim",                  # Vim
    "sqlite"                # SQLite
)

# Install all packages
foreach ($pkg in $packages) {
    Write-Host "Installing $pkg ..."
    choco install $pkg -y --no-progress
}

Write-Host "All installations completed!"
