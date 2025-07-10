Write-Host "Changing to working directory..."
cd "$(System.DefaultWorkingDirectory)"

if (Test-Path "package.json") {
    Write-Host "package.json found. Running npm install..."
    npm install
} else {
    Write-Error "package.json not found in: $(System.DefaultWorkingDirectory)"
}
