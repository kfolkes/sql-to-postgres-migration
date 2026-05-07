#!/usr/bin/env bash
# Dev container post-create setup
# Installs psql, sqlcmd, and prepares the environment for the migration lab.

set -euo pipefail

echo "=== Dev Container Post-Create Setup ==="

# --- PostgreSQL client (psql, pg_isready) ---
echo "[1/4] Installing PostgreSQL client..."
sudo apt-get update -qq
sudo apt-get install -y -qq postgresql-client > /dev/null

# --- Microsoft SQL Server tools (sqlcmd, bcp) ---
echo "[2/4] Installing SQL Server tools (sqlcmd)..."
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/ubuntu/$(lsb_release -rs)/prod $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/microsoft-prod.list > /dev/null
sudo apt-get update -qq
sudo ACCEPT_EULA=Y apt-get install -y -qq mssql-tools18 unixodbc-dev > /dev/null
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
export PATH="$PATH:/opt/mssql-tools18/bin"

# --- Prepare .env ---
echo "[3/4] Preparing environment..."
if [ ! -f .env ] && [ -f .env.example ]; then
    cp .env.example .env
    echo "  Copied .env.example → .env (edit as needed)"
else
    echo "  .env already exists"
fi

# --- Make scripts executable ---
echo "[4/4] Setting script permissions..."
chmod +x scripts/*.sh 2>/dev/null || true
chmod +x tests/performance/run-performance-tests.sh 2>/dev/null || true
chmod +x tests/security/run-security-tests.sh 2>/dev/null || true
chmod +x benchmarks/pgbench/run-benchmark.sh 2>/dev/null || true

echo ""
echo "=== Post-create setup complete ==="
echo "  psql:   $(psql --version 2>/dev/null || echo 'installed')"
echo "  sqlcmd: $(/opt/mssql-tools18/bin/sqlcmd '-?' 2>&1 | head -1 || echo 'installed')"
echo ""
