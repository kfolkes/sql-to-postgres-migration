# Database Migration Architecture Rules

These rules govern all SQL Server to PostgreSQL migrations in this repository.

## Multi-Tool Redundancy

1. **No single tool decides.** Every critical migration step must be validated by at least 2 independent tools.
2. **Iterate to consensus.** If tools disagree, investigate the discrepancy, fix it, and re-run all tools until they agree.
3. **Track results.** Every test run produces timestamped JSON. Trending is auto-generated.

## Schema Translation

1. **Document the why.** Every type, index, and SP translation must include reasoning, not just the mapping.
2. **Use idiomatic PostgreSQL.** Do not port T-SQL patterns directly - rewrite for PG idioms:
   - Cursors -> Set-based CTEs / window functions
   - `MERGE` -> `INSERT ... ON CONFLICT DO UPDATE`
   - `@@TRANCOUNT` -> Named `SAVEPOINT` / `ROLLBACK TO SAVEPOINT`
   - `CROSS APPLY` -> `LATERAL JOIN`
   - `sp_executesql` -> `EXECUTE format(...)` with `%I` / `%L`
3. **Flag incompatible patterns.** All 24 known T-SQL incompatibilities must be scanned and resolved before migration is declared complete.

## Type Mappings

| T-SQL | PostgreSQL | Reason |
|---|---|---|
| `NVARCHAR(MAX)` | `TEXT` | PG strings are Unicode natively |
| `NVARCHAR(n)` | `VARCHAR(n)` | Preserves length constraint |
| `BIT` | `BOOLEAN` | Semantically correct |
| `DECIMAL(p,s)` | `NUMERIC(p,s)` | PG convention |
| `DATETIME` / `DATETIME2` | `TIMESTAMPTZ` | Always timezone-aware |
| `UNIQUEIDENTIFIER` | `UUID` | Native PG type |
| `MONEY` | `NUMERIC(19,4)` | Locale-independent |
| `HIERARCHYID` | `ltree` or `TEXT` | Requires ltree extension |
| `GEOGRAPHY` | PostGIS `geography` | Requires PostGIS extension |
| `IMAGE` / `VARBINARY(MAX)` | `BYTEA` | PG binary type |

## Security

1. **Never hardcode credentials.** Use `.env` files (gitignored) or Azure Key Vault.
2. **Always use Entra ID passwordless auth** for Azure Database for PostgreSQL.
3. **Enable pgAudit** on all target PostgreSQL instances.
4. **Enable Microsoft Defender for Open-Source Relational DBs** on Azure PG.
5. **All PL/pgSQL functions must use parameterized queries** - no string concatenation in EXECUTE.

## Performance

1. **Always capture baseline** on source SQL Server (SSMS 22 execution plans).
2. **Always measure target** with EXPLAIN (ANALYZE, BUFFERS) on PostgreSQL.
3. **Use HammerDB TPC-C** for apples-to-apples cross-platform comparison.
4. **Enable pg_stat_statements** on all target PostgreSQL instances.
5. **Track iteration-over-iteration improvement** with timestamped JSON results.

## Testing

1. **pgtap** for functional equivalence of migrated PL/pgSQL functions.
2. **Row-count comparison** between source MSSQL and target PG for every table.
3. **DAB API regression** - same REST endpoints on both DBs must return identical data.
4. **Security tests** (sec-001 through sec-010) must all pass before migration is complete.
5. **Performance tests** (perf-001 through perf-010) must show target meets or exceeds source.

## DAB (Data API Builder)

1. DAB is **one tool among many** - not the only validation layer.
2. DAB configs for SQL Server, PostgreSQL, and Fabric SQL DB are maintained in `dab/`.
3. DAB MCP Server (`/mcp` endpoint) is one of the available MCP servers alongside GitHub MCP.
4. DAB RBAC at the API layer complements (not replaces) database-level security.

## Fabric (Optional)

1. Fabric integration is **optional** - core migration (Phases 1-3) works without it.
2. Use SqlPackage for Fabric SQL DB import.
3. MSSQL extension connects to Fabric SQL DB endpoint (same tool, new target).
4. DAB config can point at Fabric SQL DB for API-level validation.
