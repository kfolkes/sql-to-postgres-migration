# PowerShell script to validate the migration
# Usage: .\validate-migration.ps1 -Database "wide_world_importers"

param(
    [string]$Database = "wide_world_importers",
    [string]$Iteration = "run-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
)

$ErrorActionPreference = 'Stop'

Write-Host "=== Phase 3: Migration Validation ===" -ForegroundColor Cyan
Write-Host "Database: $Database"
Write-Host "Iteration: $Iteration"
Write-Host ""

# Step 1: pgtap functional tests
if (Get-Command pg_prove -ErrorAction SilentlyContinue) {
    Write-Host "[1/4] Running pgtap functional tests..." -ForegroundColor Yellow
    pg_prove -d $Database tests/pgtap/t/*.sql --verbose 2>&1
} else {
    Write-Host "[1/4] pg_prove not found - skipping" -ForegroundColor DarkYellow
}

# Step 2: Security tests
if (Get-Command pg_prove -ErrorAction SilentlyContinue) {
    Write-Host "[2/4] Running security tests..." -ForegroundColor Yellow
    pg_prove -d $Database tests/security/t/*.sql --verbose 2>&1
} else {
    Write-Host "[2/4] pg_prove not found - skipping" -ForegroundColor DarkYellow
}

# Step 3: Performance tests
Write-Host "[3/4] Running performance tests..." -ForegroundColor Yellow
if (Test-Path tests/performance/run-performance-tests.sh) {
    bash tests/performance/run-performance-tests.sh $Database $Iteration 2>&1
} else {
    Write-Host "  Performance test runner not found" -ForegroundColor DarkYellow
}

# Step 4: Row count comparison
Write-Host "[4/4] Row count comparison..." -ForegroundColor Yellow
if (Get-Command psql -ErrorAction SilentlyContinue) {
    psql -d $Database -f tests/row-count-comparison/compare.sql 2>&1
} else {
    Write-Host "  psql not found - run row count comparison manually" -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "Validation complete. Check results in tests/performance/results/$Iteration.json" -ForegroundColor Green
