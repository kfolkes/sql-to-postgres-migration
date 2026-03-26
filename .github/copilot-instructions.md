# Copilot Instructions - SQL to PostgreSQL Migration

## What This Repo Is

A **language-agnostic SQL Server to PostgreSQL migration accelerator** using multi-tool redundancy. It targets Azure Database for PostgreSQL Flexible Server with optional Microsoft Fabric integration.

## Workspace Layout

```
.github/                        # Copilot orchestration (agent, skill, prompt, rules)
dab/                            # Data API Builder configs (SQL Server, PostgreSQL, Fabric)
docs/                           # Generated phase result documents
tests/                          # Security, performance, pgtap, row-count tests
benchmarks/                     # HammerDB + pgbench configs and results
security/                       # Security baselines and hardening guides
scripts/                        # PowerShell automation scripts
samples/wide-world-importers/   # WideWorldImporters demo database assets
reference/                      # T-SQL to PL/pgSQL cheatsheet, Azure best practices
templates/                      # Reusable pgLoader and Fabric config templates
```

## Critical Conventions

- **Language-agnostic.** This repo focuses on the database layer only. No application code.
- **Multi-tool redundancy.** Every critical step must be validated by 2-3 independent tools. No single tool decides.
- **Iterate to consensus.** If tools disagree, investigate, fix, re-run until they agree.
- **Target: Azure Database for PostgreSQL Flexible Server.** Always use Entra ID passwordless auth.
- **Document the why.** Every type, index, and SP translation must include reasoning.
- **Track results.** Every test run produces timestamped JSON. Trending is auto-generated.
- **DBA persona.** Demo script and sales material use DBA language and pain points.

## The 12 Tools

1. MSSQL Extension - source schema inspector
2. PostgreSQL Extension - target schema validator
3. ora2pg - independent assessment and auto-conversion
4. pgLoader - bulk data migration with dry-run
5. DAB (Data API Builder) - API abstraction + MCP server
6. sqlfluff - PL/pgSQL linter
7. pgtap / pg_prove - PL/pgSQL unit tests
8. HammerDB - cross-platform TPC-C benchmarking
9. sec-check - security scanning
10. SSMS 22 - execution plan baseline
11. Azure Premigration Validation - connectivity/schema checks
12. Copilot Agent - orchestrates all tools

## Key Commands

```powershell
# One-click migration via Copilot Chat
# /db-migrate samples/wide-world-importers

# Manual execution
.\scripts\run-assessment.ps1
.\scripts\run-migration.ps1
.\scripts\validate-migration.ps1

# DAB (Data API Builder)
dab start --config dab/dab-config-sqlserver.json
dab start --config dab/dab-config-postgres.json

# Tests
pg_prove -d test_db tests/pgtap/t/
.\tests\performance\run-performance-tests.sh
.\tests\security\run-security-tests.sh
```

## When Editing Agent, Skill, or Prompt Files

- Agent definition (`.github/agents/db-migration.agent.md`) declares tool access - keep `tools:` in sync.
- Skill file (`.github/skills/sql-to-postgres/SKILL.md`) is the single source of truth for orchestration.
- Prompt file (`.github/prompts/db-migrate.prompt.md`) binds to `db-migration` agent.
- Rules (`.github/rules/database-rules.md`) govern all schema translations and testing requirements.
