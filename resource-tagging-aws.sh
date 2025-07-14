# Define the stage names
$stageNames = @(
    "$(HCC.QA.NewServices.Qa.StageName)",
    "$(HCC.QA.NewServices.B2B.StageName)"
)

# Track overall status
$allSucceededOrFailed = $true

foreach ($stageName in $stageNames) {
    $envVarName = "RELEASE_ENVIRONMENTS_${stageName}_STATUS"
    Write-Output "Checking status for: $envVarName"

    $status = Get-Content env:$envVarName
    Write-Output "Status of ${stageName}: ${status}"

    if ($status -ne "succeeded" -and $status -ne "failed") {
        $allSucceededOrFailed = $false
        break
    }
}

if ($allSucceededOrFailed) {
    Write-Output "All stages are done. Proceeding to copy from fileshare..."

    # Set environment variables
    $env:AZCOPY_LOG_LOCATION = "$(System.DefaultWorkingDirectory)"
    $env:AZCOPY_AUTO_LOGIN_TYPE = "MSI"

    $azcopy = "$(System.DefaultWorkingDirectory)\azcopy.exe"

    # Login
    & $azcopy login --login-type=MSI --log-level=DEBUG --tenant-id "$(ReleasePipeline.TenantID)"

    # Copy Allure Results
    $allureSource = "$(ReleasePipeline.StorageAccount)/$(ReleasePipeline.ReportFolder)/$(Release.DefinitionName)/$(releasenumber)/allure-results/*"
    $allureTarget = "$(System.DefaultWorkingDirectory)\allure-results"
    Write-Output "Copying Allure results..."
    & $azcopy copy $allureSource $allureTarget --recursive --log-level=DEBUG

    # Copy Cypress Results
    $cypressSource = "$(ReleasePipeline.StorageAccount)/$(ReleasePipeline.ReportFolder)/$(Release.DefinitionName)/$(releasenumber)/cypress/results/*"
    $cypressTarget = "$(System.DefaultWorkingDirectory)\cypress\results"
    Write-Output "Copying Cypress results..."
    & $azcopy copy $cypressSource $cypressTarget --recursive --log-level=DEBUG

    Write-Output "Copy operations complete."
} else {
    Write-Output "One or more test stages are not complete. Skipping copy."
}



,,

cd "$(System.DefaultWorkingDirectory)"
npx allure generate "allure-results" --clean -o "allure-report-full"

