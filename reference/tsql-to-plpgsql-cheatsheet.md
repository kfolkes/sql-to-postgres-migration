# T-SQL to PL/pgSQL Cheatsheet

Quick reference for the 24 incompatible T-SQL patterns and their PostgreSQL equivalents.

## HIGH Severity (Requires Rewrite)

| # | T-SQL Pattern | PostgreSQL Alternative | Notes |
|---|---|---|---|
| 1 | `DECLARE CURSOR` / `FETCH NEXT` | Set-based CTE, window function, `LATERAL JOIN` | Cursors exist in PG but are 10-100x slower than set-based |
| 12 | `MERGE` statement | `INSERT ... ON CONFLICT DO UPDATE` (upsert) | PG 15+ has MERGE but upsert is more idiomatic |
| 17 | `@@TRANCOUNT` / nested transactions | Named `SAVEPOINT` / `ROLLBACK TO SAVEPOINT` | PG savepoints are named, not counted |
| 18 | `HIERARCHYID` (CLR type) | `ltree` extension or recursive CTE + materialized path | Requires PostGIS or ltree extension |
| 19 | `GEOGRAPHY` / `GEOMETRY` | PostGIS `geography` / `geometry` types | Requires PostGIS extension |
| 23 | Linked servers | `postgres_fdw` extension (Foreign Data Wrapper) | Different connection model |
| 24 | `OPENROWSET` / `OPENQUERY` | `postgres_fdw`, `file_fdw`, or `dblink` | External data access pattern differs |

## MEDIUM Severity (Syntax Change)

| # | T-SQL | PL/pgSQL | Example |
|---|---|---|---|
| 2 | `@@ROWCOUNT` | `GET DIAGNOSTICS row_count = ROW_COUNT` or `FOUND` | `IF FOUND THEN ...` |
| 3 | `@@IDENTITY` / `SCOPE_IDENTITY()` | `RETURNING id` clause or `currval('seq')` | `INSERT ... RETURNING id` |
| 9 | `CROSS APPLY` / `OUTER APPLY` | `LATERAL JOIN` | `FROM t1, LATERAL (SELECT ...) t2` |
| 11 | `TRY_CAST` / `TRY_CONVERT` | Custom function or `CASE WHEN` | Write safe_cast helper |
| 13 | `#TempTable` | `CREATE TEMP TABLE temp_name (...)` | Must use explicit CREATE |
| 14 | `DECLARE @t TABLE` (table variable) | `CREATE TEMP TABLE` or CTE | CTEs preferred for read-only |
| 16 | `BEGIN TRY/CATCH` | `BEGIN...EXCEPTION WHEN OTHERS THEN...END` | Block-scoped exception handling |
| 22 | `sp_executesql` | `EXECUTE format(...)` with `%I`/`%L` | `%I`=identifier, `%L`=literal (SQL injection safe) |

## LOW Severity (Simple Swap)

| # | T-SQL | PL/pgSQL | Notes |
|---|---|---|---|
| 4 | `ISNULL(a, b)` | `COALESCE(a, b)` | ANSI standard |
| 5 | `NEWID()` | `gen_random_uuid()` | PG 13+ built-in |
| 6 | `GETDATE()` / `SYSDATETIME()` | `NOW()` / `CURRENT_TIMESTAMP` | |
| 7 | `TOP N` | `LIMIT N` | |
| 8 | `WITH (NOLOCK)` | Remove entirely | PG MVCC: readers never block writers |
| 10 | `STUFF()` | `string_agg()` or `OVERLAY()` | |
| 15 | `RAISERROR('msg', 16, 1, @var)` | `RAISE EXCEPTION 'msg: %', var` | No severity/state params |
| 20 | `OUTPUT` clause (INSERT...OUTPUT) | `RETURNING *` | |
| 21 | `WAITFOR DELAY` | `pg_sleep()` | |

## Type Mapping Reference

| T-SQL | PostgreSQL | Why |
|---|---|---|
| `NVARCHAR(MAX)` | `TEXT` | PG strings are Unicode natively |
| `NVARCHAR(n)` | `VARCHAR(n)` | Preserves length constraint |
| `BIT` | `BOOLEAN` | TRUE/FALSE vs 0/1 |
| `DECIMAL(p,s)` | `NUMERIC(p,s)` | PG convention |
| `DATETIME` / `DATETIME2` | `TIMESTAMPTZ` | Always timezone-aware |
| `UNIQUEIDENTIFIER` | `UUID` | Native PG type |
| `INT IDENTITY(1,1)` | `INTEGER GENERATED ALWAYS AS IDENTITY` | SQL:2003 standard |
| `MONEY` | `NUMERIC(19,4)` | PG MONEY is locale-dependent |
| `IMAGE` / `VARBINARY(MAX)` | `BYTEA` | PG binary type |
| `XML` | `XML` or `JSONB` | Consider JSONB for semi-structured |
| `SQL_VARIANT` | `JSONB` | Closest PG equivalent |

## Variable Declaration

```sql
-- T-SQL
DECLARE @CurrentStock INT;
SET @CurrentStock = 100;

-- PL/pgSQL
DECLARE
  v_current_stock INTEGER;
BEGIN
  v_current_stock := 100;
```

## Error Handling

```sql
-- T-SQL
BEGIN TRY
  -- risky code
END TRY
BEGIN CATCH
  ROLLBACK;
  THROW;
END CATCH

-- PL/pgSQL
BEGIN
  -- risky code
EXCEPTION WHEN OTHERS THEN
  RAISE;
END;
```

## Pagination

```sql
-- T-SQL
SELECT * FROM Products
ORDER BY Name
OFFSET 20 ROWS FETCH NEXT 10 ROWS ONLY;

-- PL/pgSQL
SELECT * FROM products
ORDER BY name
LIMIT 10 OFFSET 20;
```
