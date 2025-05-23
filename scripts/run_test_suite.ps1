param (
    [string]$Model = "models/20250328-215011-commutative-wasabi.tar.gz",
    [string]$Port = "5007",
    [string[]]$Categories = @()
)

# Get the current directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptPath

Write-Host "Starting the test suite..."
Write-Host "Model: $Model"
Write-Host "Port: $Port"

# Start the Rasa server in the background
$serverJob = Start-Job -ScriptBlock {
    param($projectRoot, $model, $port)
    Set-Location $projectRoot
    python -m rasa run --model $model --port $port --enable-api
} -ArgumentList $projectRoot, $Model, $Port

Write-Host "Waiting for the server to start..."
Start-Sleep -Seconds 15

# Run the test script
try {
    Set-Location $projectRoot
    
    $testCommand = "python $scriptPath/test_chatbot.py"
    if ($Categories.Count -gt 0) {
        $testCommand = "$testCommand $($Categories -join ' ')"
    }
    
    Write-Host "Running test script: $testCommand"
    Invoke-Expression $testCommand
}
catch {
    Write-Host "Error running test script: $_" -ForegroundColor Red
}
finally {
    # Stop the Rasa server job
    Write-Host "Stopping the Rasa server..."
    Stop-Job -Job $serverJob
    Remove-Job -Job $serverJob -Force
    
    Write-Host "Test suite completed."
} 