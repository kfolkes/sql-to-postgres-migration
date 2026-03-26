# PowerShell script to run source database assessment
# Usage: .\run-assessment.ps1 -ConnectionString "Server=localhost;Database=WideWorldImporters;Trusted_Connection=True;"

param(
    [Parameter(Mandatory=$true)]
    [string]$ConnectionString,
    
    [string]$OutputDir = "docs"
)

$ErrorActionPreference = 'Stop'

Write-Host "=== Phase 1: Source Database Assessment ===" -ForegroundColor Cyan
Write-Host "Connection: $($ConnectionString.Substring(0, [Math]::Min(50, $ConnectionString.Length)))..."
Write-Host "Output: $OutputDir/"
Write-Host ""

# Step 1: ora2pg assessment (if available)
if (Get-Command ora2pg -ErrorAction SilentlyContinue) {
    Write-Host "[1/4] Running ora2pg assessment..." -ForegroundColor Yellow
    ora2pg -t SHOW_REPORT -c samples/wide-world-importers/ora2pg.conf 2>&1 | Tee-Object -FilePath "$OutputDir/ora2pg-report.txt"
} else {
    Write-Host "[1/4] ora2pg not found - skipping (install: https://ora2pg.darold.net)" -ForegroundColor DarkYellow
}

# Step 2: DAB entity discovery (if available)
if (Get-Command dab -ErrorAction SilentlyContinue) {
    Write-Host "[2/4] Running DAB entity discovery..." -ForegroundColor Yellow
    $env:SQLSERVER_CONN = $ConnectionString
    dab init --database-type mssql --connection-string "@env('SQLSERVER_CONN')" --host-mode development --config dab/dab-config-discovery.json 2>&1
    Write-Host "  DAB entity discovery complete. Review dab/dab-config-discovery.json"
} else {
    Write-Host "[2/4] DAB CLI not found - skipping (install: dotnet tool install microsoft.dataapibuilder -g)" -ForegroundColor DarkYellow
}

# Step 3: sec-check baseline (if available)
if (Get-Command agentsec -ErrorAction SilentlyContinue) {
    Write-Host "[3/4] Running sec-check security baseline..." -ForegroundColor Yellow
    agentsec scan samples/ --output security/sec-check-results/source-scan.json 2>&1
} else {
    Write-Host "[3/4] sec-check not found - skipping (install from sec-check repo)" -ForegroundColor DarkYellow
}

Write-Host "[4/4] Assessment complete." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Connect to source DB via MSSQL extension in VS Code"
Write-Host "  2. Run /db-migrate in Copilot Chat for full agent-driven assessment"
Write-Host "  3. Or run .\scripts\run-migration.ps1 for Phase 2"
