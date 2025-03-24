# Install .NET 9 SDK
Invoke-WebRequest -Uri https://dot.net/v1/dotnet-install.ps1 -OutFile dotnet-install.ps1
.\dotnet-install.ps1 -Channel 9.0

# Install ASPIRE CLI
dotnet tool install -g Aspire.Cli

# Deploy SalesApp
$salesAppPath = "C:\SalesApp"
if (-Not (Test-Path $salesAppPath)) {
    New-Item -ItemType Directory -Path $salesAppPath
}
# Copy your app files here (e.g., from a GitHub repo or S3 bucket)
# Example: Invoke-WebRequest -Uri "https://your-repo/SalesApp.zip" -OutFile "$salesAppPath\SalesApp.zip"
# Expand-Archive -Path "$salesAppPath\SalesApp.zip" -DestinationPath $salesAppPath

# Configure IIS for SalesApp
New-WebSite -Name "SalesApp" -PhysicalPath $salesAppPath -Port 80

# Deploy ASPIRE
$aspirePath = "C:\AspireApp"
if (-Not (Test-Path $aspirePath)) {
    New-Item -ItemType Directory -Path $aspirePath
}
# Copy your ASPIRE files here
# Example: Invoke-WebRequest -Uri "https://your-repo/AspireApp.zip" -OutFile "$aspirePath\AspireApp.zip"
# Expand-Archive -Path "$aspirePath\AspireApp.zip" -DestinationPath $aspirePath

# Run ASPIRE
Set-Location $aspirePath
aspire run