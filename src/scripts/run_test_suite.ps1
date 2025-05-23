param(
    [string]$Model = ""
)

# Enable verbose output
$VerbosePreference = 'Continue'
$ErrorActionPreference = 'Stop'

# Function to get the newest model file
function Get-NewestModel {
    Write-Verbose "Searching for the newest model in ../models/"
    $modelPath = "..\models"
    $newestModel = Get-ChildItem -Path $modelPath -Filter "*.tar.gz" | 
        Sort-Object LastWriteTime -Descending | 
        Select-Object -First 1
    if ($null -eq $newestModel) {
        throw "No model files found in $modelPath"
    }
    return $newestModel.FullName
}

# Function to check if virtual environment is activated
function Test-VenvActivated {
    return $env:VIRTUAL_ENV -ne $null
}

# Function to activate virtual environment
function Activate-Venv {
    Write-Verbose "Checking virtual environment status"
    if (-not (Test-VenvActivated)) {
        Write-Host "Activating virtual environment..."
        try {
            & "..\venv\Scripts\Activate.ps1"
            if (-not (Test-VenvActivated)) {
                throw "Failed to activate virtual environment"
            }
        }
        catch {
            throw "Error activating virtual environment: $_"
        }
    }
    Write-Verbose "Virtual environment is active"
}

# Main execution block
try {
    Write-Host "Starting test suite execution..." -ForegroundColor Green

    # Activate virtual environment
    Activate-Venv

    # Verify Rasa installation
    Write-Verbose "Verifying Rasa installation"
    $rasaVersion = python -m rasa --version
    Write-Host "Rasa version: $rasaVersion"

    # Determine model to use
    if ([string]::IsNullOrEmpty($Model)) {
        $Model = Get-NewestModel
        Write-Host "Using newest model: $Model"
    }
    else {
        Write-Host "Using specified model: $Model"
    }

    # Start Rasa server
    Write-Host "Starting Rasa server..." -ForegroundColor Yellow
    $rasaServer = Start-Process -FilePath "python" -ArgumentList "-m rasa run --model $Model" -PassThru -WindowStyle Hidden
    Write-Verbose "Rasa server started with PID: $($rasaServer.Id)"

    # Wait for server to initialize
    Write-Host "Waiting for server to initialize..."
    Start-Sleep -Seconds 10

    # Run tests
    Write-Host "Running tests..." -ForegroundColor Yellow
    python -m rasa test

    Write-Host "Tests completed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "Error occurred during test execution:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}
finally {
    # Cleanup
    Write-Host "Cleaning up processes..." -ForegroundColor Yellow
    if ($rasaServer) {
        Write-Verbose "Stopping Rasa server (PID: $($rasaServer.Id))"
        Stop-Process -Id $rasaServer.Id -Force -ErrorAction SilentlyContinue
    }
    
    # Kill any remaining python processes related to Rasa
    Get-Process -Name "python" | Where-Object {$_.CommandLine -like "*rasa*"} | ForEach-Object {
        Write-Verbose "Stopping process: $($_.Id)"
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }

    Write-Host "Cleanup completed" -ForegroundColor Green
}

