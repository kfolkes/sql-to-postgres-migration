# Local environment setup: SQL Server to PostgreSQL Migration
# Usage: .\scripts\setup-local-env.ps1

param(
    [string]$SaPassword = "Str0ngP@ssw0rd!",
    [string]$PgPassword = "Str0ngP@ssw0rd!"
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  SQL Server to PostgreSQL - Local Setup" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check prerequisites
Write-Host "[1/6] Checking prerequisites..." -ForegroundColor Yellow

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "  ERROR: Docker not found. Install Docker Desktop: https://docker.com/products/docker-desktop" -ForegroundColor Red
    exit 1
}

$dockerInfo = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ERROR: Docker is not running. Start Docker Desktop and try again." -ForegroundColor Red
    exit 1
}
Write-Host "  Docker is running." -ForegroundColor Green

# Step 2: Create data directory for backup cache
Write-Host "[2/6] Preparing data directory..." -ForegroundColor Yellow
$dataDir = Join-Path $PSScriptRoot "..\data"
if (-not (Test-Path $dataDir)) {
    New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
    Write-Host "  Created ./data/ directory for backup cache."
}
else {
    Write-Host "  ./data/ directory exists."
}

# Step 3: Start containers
Write-Host "[3/6] Starting Docker containers..." -ForegroundColor Yellow

$env:SA_PASSWORD = $SaPassword
$env:PG_PASSWORD = $PgPassword

Push-Location (Join-Path $PSScriptRoot "..")
try {
    docker compose up -d
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ERROR: docker compose up failed." -ForegroundColor Red
        exit 1
    }
}
finally {
    Pop-Location
}
Write-Host "  Containers started." -ForegroundColor Green

# Step 4: Wait for SQL Server to be healthy
Write-Host "[4/6] Waiting for SQL Server to be ready..." -ForegroundColor Yellow
$maxAttempts = 30
for ($i = 1; $i -le $maxAttempts; $i++) {
    $result = docker exec wwi-sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $SaPassword -C -Q "SELECT 1" -b 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  SQL Server is ready." -ForegroundColor Green
        break
    }
    if ($i -eq $maxAttempts) {
        Write-Host "  ERROR: SQL Server did not start within $($maxAttempts * 10) seconds." -ForegroundColor Red
        Write-Host "  Check: docker logs wwi-sqlserver" -ForegroundColor DarkYellow
        exit 1
    }
    Write-Host "  Attempt $i/$maxAttempts - waiting 10s..."
    Start-Sleep -Seconds 10
}

# Step 5: Download and restore WideWorldImporters
Write-Host "[5/6] Setting up WideWorldImporters database..." -ForegroundColor Yellow

# Copy setup script into container and execute it
docker exec wwi-sqlserver bash -c "chmod +x /backup/sqlserver-setup.sh 2>/dev/null; true"

# Check if the setup script is accessible via the volume mount
$setupScript = Join-Path $PSScriptRoot "docker\sqlserver-setup.sh"
$bakPath = Join-Path $dataDir "WideWorldImporters-Full.bak"

# Download backup from host if not cached (faster than downloading inside container)
if (-not (Test-Path $bakPath)) {
    Write-Host "  Downloading WideWorldImporters-Full.bak (~120MB)..." -ForegroundColor DarkYellow
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri "https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak" -OutFile $bakPath
    $ProgressPreference = 'Continue'
    Write-Host "  Download complete." -ForegroundColor Green
}
else {
    Write-Host "  Backup already cached at ./data/WideWorldImporters-Full.bak" -ForegroundColor Green
}

# Check if database already exists
$dbExists = docker exec wwi-sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $SaPassword -C -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM sys.databases WHERE name = 'WideWorldImporters'" -h -1 -b 2>&1
$dbExists = ($dbExists | Out-String).Trim()

if ($dbExists -eq "1") {
    Write-Host "  WideWorldImporters already restored. Skipping." -ForegroundColor Green
}
else {
    Write-Host "  Restoring WideWorldImporters database..."
    docker exec wwi-sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $SaPassword -C -Q "
        RESTORE DATABASE WideWorldImporters
        FROM DISK = '/backup/WideWorldImporters-Full.bak'
        WITH MOVE 'WWI_Primary' TO '/var/opt/mssql/data/WideWorldImporters.mdf',
             MOVE 'WWI_UserData' TO '/var/opt/mssql/data/WideWorldImporters_UserData.ndf',
             MOVE 'WWI_Log' TO '/var/opt/mssql/data/WideWorldImporters.ldf',
             MOVE 'WWI_InMemory_Data_1' TO '/var/opt/mssql/data/WideWorldImporters_InMemory.ndf',
             REPLACE;
    " -b

    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ERROR: Database restore failed." -ForegroundColor Red
        Write-Host "  Check: docker logs wwi-sqlserver" -ForegroundColor DarkYellow
        exit 1
    }
    Write-Host "  Restore complete." -ForegroundColor Green
}

# Step 6: Wait for PostgreSQL and verify
Write-Host "[6/6] Verifying PostgreSQL..." -ForegroundColor Yellow
$maxAttempts = 15
for ($i = 1; $i -le $maxAttempts; $i++) {
    $result = docker exec wwi-postgres pg_isready -U wwi_user -d wide_world_importers 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  PostgreSQL is ready." -ForegroundColor Green
        break
    }
    if ($i -eq $maxAttempts) {
        Write-Host "  ERROR: PostgreSQL did not start." -ForegroundColor Red
        exit 1
    }
    Start-Sleep -Seconds 5
}

# Verify schemas were created
$pgSchemas = docker exec wwi-postgres psql -U wwi_user -d wide_world_importers -t -c "SELECT string_agg(schema_name, ', ' ORDER BY schema_name) FROM information_schema.schemata WHERE schema_name IN ('warehouse','sales','purchasing','application','integration','sequences','website');" 2>&1
Write-Host "  PostgreSQL schemas: $($pgSchemas | Out-String)".Trim() -ForegroundColor Green

# Summary
Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host "  Local Environment Ready!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "  SQL Server:  localhost,1433  |  sa / $SaPassword  |  DB: WideWorldImporters" -ForegroundColor White
Write-Host "  PostgreSQL:  localhost:5432  |  wwi_user / $PgPassword  |  DB: wide_world_importers" -ForegroundColor White
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor Cyan
Write-Host "    1. Connect to SQL Server via MSSQL extension (profile pre-configured in settings.json)"
Write-Host "    2. Connect to PostgreSQL via PG extension"
Write-Host "    3. Run: /db-migrate samples/wide-world-importers"
Write-Host ""
Write-Host "  Useful commands:" -ForegroundColor Cyan
Write-Host "    docker compose ps          # Check container status"
Write-Host "    docker compose logs -f     # Tail container logs"
Write-Host "    docker compose down        # Stop containers"
Write-Host "    docker compose down -v     # Stop + delete volumes (full reset)"
Write-Host ""
