# Define the stage names
$stageNames = @(
    "$(HCC.QA.NewServices.Qa.StageName)",
    "$(HCC.QA.NewServices.B2B.StageName)"
)

# Var to track the overall status
$allSucceededOrFailed = $true

# Loop through stages
foreach ($stageName in $stageNames) {
    # Construct environment variable name
    $envVarName = "RELEASE_ENVIRONMENTS_${stageName}_STATUS"

    echo $envVarName

    # Retrieve status from pipeline
    $status = Get-Content env:$envVarName

    # Output the status for debugging purposes
    Write-Output "Status of ${stageName}: ${status}"

    # Check if status is neither succeeded nor failed
    if ($status -ne "succeeded" -and $status -ne "failed") {
        $allSucceededOrFailed = $false
        break
    }
}

# Execute if all stages are either succeeded or failed
if ($allSucceededOrFailed) {

    Write-Output "All stages have either succeeded or failed. Copying files from fileshare..."
    echo "echo $(System.DefaultWorkingDirectory)"
    echo $(System.DefaultWorkingDirectory)

    echo "set AZCOPY_LOG_LOCATION=$(System.DefaultWorkingDirectory)"
    set AZCOPY_LOG_LOCATION=$(System.DefaultWorkingDirectory)

    echo "set AZCOPY_AUTO_LOGIN_TYPE=MSI"
    set AZCOPY_AUTO_LOGIN_TYPE=MSI

    
    echo "$(System.DefaultWorkingDirectory)\artifact\$(Build.BuildId)\azcopy.exe login --login-type=MSI --log-level=DEBUG --tenant-id "$(ReleasePipeline.TenantID)""

    $(System.DefaultWorkingDirectory)\artifact\$(Build.BuildId)\azcopy.exe login --login-type=MSI --log-level=DEBUG --tenant-id "$(ReleasePipeline.TenantID)"

    
    echo "$(System.DefaultWorkingDirectory)\artifact\$(Build.BuildId)\azcopy.exe copy "$(ReleasePipeline.StorageAccount)/$(ReleasePipeline.ReportFolder)/$(Release.DefinitionName)/$(releasenumber)/allure-results/*" "$(System.DefaultWorkingDirectory)\artifact\$(Build.BuildId)\allure-results" --recursive --log-level=DEBUG"
    
    $(System.DefaultWorkingDirectory)\artifact\$(Build.BuildId)\azcopy.exe copy "$(ReleasePipeline.StorageAccount)/$(ReleasePipeline.ReportFolder)/$(Release.DefinitionName)/$(releasenumber)/allure-results/*" "$(System.DefaultWorkingDirectory)\artifact\$(Build.BuildId)\allure-results" --recursive --log-level=DEBUG



echo "$(System.DefaultWorkingDirectory)\artifact\$(Build.BuildId)\azcopy.exe copy "$(ReleasePipeline.StorageAccount)/$(ReleasePipeline.ReportFolder)/$(Release.DefinitionName)/$(releasenumber)/cypress/results/*" "$(System.DefaultWorkingDirectory)\artifact\$(Build.BuildId)\cypress\results" --recursive --log-level=DEBUG"
    
    $(System.DefaultWorkingDirectory)\artifact\$(Build.BuildId)\azcopy.exe copy "$(ReleasePipeline.StorageAccount)/$(ReleasePipeline.ReportFolder)/$(Release.DefinitionName)/$(releasenumber)/cypress/results/*" "$(System.DefaultWorkingDirectory)\artifact\$(Build.BuildId)\cypress\results" --recursive --log-level=DEBUG


    # Invoke-MyCommand
} else {
    Write-Output "One or more test stages have a status other than succeeded or failed."
}
