param (
    [string]$Config = "config.yml",
    [string]$Domain = "domain.yml",
    [switch]$Debug
)

Write-Host "Starting full Rasa training..."

# Get the current directory as the base path
$basePath = $PWD.Path

# Check if required files exist
if (-not (Test-Path $Config)) {
    Write-Error "Config file not found: $Config"
    exit 1
}

if (-not (Test-Path $Domain)) {
    Write-Error "Domain file not found: $Domain"
    exit 1
}

# Define specific data paths to use with absolute paths
$NluData = Join-Path $basePath "data\nlu"
$RulesData = Join-Path $basePath "data\rules"
$StoriesData = Join-Path $basePath "data\stories"

if (-not (Test-Path $NluData)) {
    Write-Error "NLU data directory not found: $NluData"
    exit 1
}

if (-not (Test-Path $RulesData)) {
    Write-Error "Rules data directory not found: $RulesData"
    exit 1
}

if (-not (Test-Path $StoriesData)) {
    Write-Error "Stories data directory not found: $StoriesData"
    exit 1
}

Write-Host "Using the following data directories:"
Write-Host "- NLU: $NluData"
Write-Host "- Rules: $RulesData"
Write-Host "- Stories: $StoriesData"

# Build the training command with specific data paths
$command = "rasa train --config `"$Config`" --domain `"$Domain`" --data `"$NluData`",`"$RulesData`",`"$StoriesData`""

# Add debug flag if specified
if ($Debug) {
    $command += " --debug"
}

# Execute the training command
Write-Host "Executing: $command"
try {
    Invoke-Expression $command
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Training completed successfully!"
    } else {
        Write-Error "Training failed with exit code: $LASTEXITCODE"
        exit $LASTEXITCODE
    }
} catch {
    Write-Error "An error occurred during training: $_"
    exit 1
}

