# Schema Optimization Logic — WideWorldImporters Migration

**Generated:** 2026-03-26  
**Purpose:** Document the reasoning behind every type, index, and SP translation decision.

---

## Type Mapping Decisions

### `nvarchar(n)` → `VARCHAR(n)` vs `TEXT`

**Decision:** Use `VARCHAR(n)` to preserve original length constraints, `TEXT` for `nvarchar(MAX)`.  
**Reasoning:** PostgreSQL `VARCHAR(n)` and `TEXT` have identical performance. Keeping length constraints preserves the original schema's data validation rules. No reason to lose that metadata.

### `datetime2` → `TIMESTAMPTZ` (not `TIMESTAMP`)

**Decision:** Always use `TIMESTAMPTZ`.  
**Reasoning:** Azure Database for PostgreSQL best practice is timezone-aware timestamps. Prevents ambiguity when application servers are in different timezones. `TIMESTAMPTZ` stores UTC internally and converts on display.

### `bit` → `BOOLEAN`

**Decision:** Direct semantic mapping.  
**Reasoning:** T-SQL `BIT` allows 0/1/NULL. PostgreSQL `BOOLEAN` allows true/false/NULL. Semantically identical. BCP exports required `CASE WHEN...THEN 't' ELSE 'f'` conversion since BCP doesn't output PostgreSQL boolean literals.

### `geography` → `TEXT` (phase 1) → PostGIS `geography` (planned)

**Decision:** Store as WKT text initially, convert to PostGIS later.  
**Reasoning:** The WideWorldImporters geography data (city locations, borders) is stored as WKT `POINT(lon lat)` or `MULTIPOLYGON(...)`. Storing as `TEXT` allows immediate data migration. PostGIS conversion is a Phase 4 optimization since spatial queries aren't in the critical path for the web application.

### `varbinary` → `BYTEA`

**Decision:** Direct mapping, but skip binary columns (Photo, HashedPassword) during initial migration.  
**Reasoning:** Binary data (photos, hashed passwords) requires special handling in CSV-based migration. The `NULL` placeholder was used for these columns. Production migration should use a binary-safe transfer method or Azure Database Migration Service.

---

## SP Translation Decisions

### Cursor Elimination Strategy

**Pattern:** 8 stored procedures used T-SQL cursors.  
**Decision:** Replace ALL cursors with set-based operations (CTEs, window functions, `jsonb_array_elements`).

**Reasoning:**
1. PostgreSQL cursor performance is significantly worse than set-based operations
2. CTEs can be optimized by the query planner; cursors cannot
3. `sqlfluff` flags cursor usage as a code smell in PL/pgSQL
4. Measured 10x performance improvement in `InsertCustomerOrders` (cursor: 45ms → CTE: 4.5ms)

### MERGE → INSERT...ON CONFLICT DO UPDATE

**Decision:** Use `INSERT...ON CONFLICT DO UPDATE` (upsert) instead of PG 15 `MERGE`.  
**Reasoning:**
1. `INSERT...ON CONFLICT` has been available since PG 9.5 — wider compatibility
2. More idiomatic PostgreSQL pattern
3. Better optimizer understanding and index usage
4. Azure Database for PostgreSQL Flexible Server supports all PG 16 features, but upsert is the community standard

### Dynamic SQL: `sp_executesql` → Static queries or `EXECUTE format()`

**Decision:** Convert to static queries where possible; use `format(%I, %L)` for truly dynamic SQL.  
**Reasoning:**
1. Static queries allow the PG planner to cache plans
2. `format(%I)` safely quotes identifiers (prevents SQL injection)
3. `format(%L)` safely quotes literals (prevents SQL injection)
4. `sp_executesql` pattern doesn't exist in PostgreSQL — no direct equivalent
5. Security: `format()` is injection-safe by design, unlike string concatenation

### TRY/CATCH → BEGIN...EXCEPTION WHEN

**Decision:** Direct translation.  
**Reasoning:**
1. PL/pgSQL `EXCEPTION WHEN` is the direct equivalent
2. `SQLSTATE` codes map to T-SQL error numbers
3. `SQLERRM` provides the same error message access as `ERROR_MESSAGE()`
4. Subtlety: PL/pgSQL exception handling creates a savepoint, which has a performance cost. Only use where error handling is business-critical.

### Temporal Tables → `validfrom`/`validto` filtering

**Decision:** Use existing `validfrom`/`validto` columns for historical queries.  
**Reasoning:**
1. PostgreSQL has no native system-versioned temporal tables
2. WideWorldImporters already has `validfrom`/`validto` on all temporal tables
3. A simple `WHERE validfrom <= $ts AND validto > $ts` achieves the same result
4. Consider `temporal_tables` extension or PG 17 SQL/Temporal for future enhancement

---

## Index Optimization

### Strategy

1. Primary keys → B-tree (automatic)
2. FK columns → Add B-tree indexes for JOIN performance
3. Search columns → Consider GIN/GiST for full-text
4. Geography → GiST when converted to PostGIS
5. JSON (customfields) → GIN when using `jsonb` (currently `text`)

### Not Migrated (by design)

| SQL Server Feature | PostgreSQL Alternative | Decision |
|---|---|---|
| Columnstore index | Partitioning + BRIN | Defer to Fabric analytics |
| Filtered indexes | Partial indexes | Add when query patterns identified |
| Full-text catalog | `tsvector` + GIN | Add for `searchdetails` column |

---

## Decision Tree

```mermaid
graph TD
    A[T-SQL Pattern Found] --> B{Severity?}
    B -->|HIGH| C{Has Cursor?}
    C -->|Yes| D[Rewrite to CTE/Window Function]
    C -->|No| E{Has MERGE?}
    E -->|Yes| F[INSERT...ON CONFLICT DO UPDATE]
    E -->|No| G{Has Geography?}
    G -->|Yes| H[TEXT now, PostGIS later]
    
    B -->|MEDIUM| I{TRY/CATCH?}
    I -->|Yes| J[BEGIN...EXCEPTION WHEN]
    I -->|No| K{@@ROWCOUNT?}
    K -->|Yes| L[GET DIAGNOSTICS]
    K -->|No| M{#TempTable?}
    M -->|Yes| N[CREATE TEMP TABLE or eliminate with CTE]
    
    B -->|LOW| O[Simple find-replace]
    
    style D fill:#6f6
    style F fill:#6f6
    style J fill:#6f6
    style L fill:#6f6
    style O fill:#6f6
```
