# PowerShell script to execute the migration
# Usage: .\run-migration.ps1

param(
    [string]$PgLoaderConfig = "samples/wide-world-importers/migration-scripts/pgloader.conf",
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

Write-Host "=== Phase 2: Migration Execution ===" -ForegroundColor Cyan
Write-Host "pgLoader config: $PgLoaderConfig"
Write-Host ""

# Step 1: pgLoader dry run
if (Get-Command pgloader -ErrorAction SilentlyContinue) {
    if ($DryRun -or $true) {
        Write-Host "[1/3] Running pgLoader dry-run (validation only)..." -ForegroundColor Yellow
        pgloader --dry-run $PgLoaderConfig 2>&1
        Write-Host "  Dry-run complete. Review output for type mapping issues." -ForegroundColor Green
    }
    
    if (-not $DryRun) {
        Write-Host ""
        $confirm = Read-Host "Proceed with actual data migration? (y/N)"
        if ($confirm -eq 'y') {
            Write-Host "[2/3] Running pgLoader data transfer..." -ForegroundColor Yellow
            pgloader $PgLoaderConfig 2>&1
            Write-Host "  Data transfer complete." -ForegroundColor Green
        } else {
            Write-Host "  Migration aborted by user." -ForegroundColor DarkYellow
            exit 0
        }
    }
} else {
    Write-Host "pgLoader not found. Install: https://pgloader.io" -ForegroundColor Red
    exit 1
}

# Step 2: sqlfluff lint
if (Get-Command sqlfluff -ErrorAction SilentlyContinue) {
    Write-Host "[3/3] Linting PL/pgSQL with sqlfluff..." -ForegroundColor Yellow
    sqlfluff lint samples/wide-world-importers/migration-scripts/tsql-to-plpgsql/ --dialect postgres 2>&1
} else {
    Write-Host "[3/3] sqlfluff not found - skipping (install: pip install sqlfluff)" -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "Migration execution complete. Run .\scripts\validate-migration.ps1 for Phase 3." -ForegroundColor Green
