# DEMO SCRIPT: SQL Server to PostgreSQL Migration

**Audience:** SSEs, DBAs, Engineering Leaders
**Duration:** 15-20 minutes
**Persona:** Senior DBA managing 200+ SQL Server databases

---

## Opening (60 seconds)

> "You manage 200 SQL Server databases. Licensing costs $15,000 per core per year. Every time someone says 'just move to Postgres', you think about 6-12 months of stored procedure rewrites, weekend cutovers, and praying nothing breaks."
>
> "Today I'm going to show you how to do it differently. One Copilot prompt. Twelve tools cross-validating every step. Tracked performance and security metrics. And the database swap happens with zero application changes."

---

## Scene 1: One-Click Assessment (3 minutes)

### Narration
> "Let's start with the WideWorldImporters database. 15 tables, 30 stored procedures, temporal tables, HIERARCHYID columns, GEOGRAPHY data. The kind of database that makes DBAs say 'this can't be automated'."

### Actions
1. Open VS Code with this repo
2. Open Copilot Chat
3. Type: `/db-migrate samples/wide-world-importers`
4. Show MSSQL extension connecting to SQL Server
5. Show schema discovery: tables, SPs, triggers extracted
6. Show T-SQL incompatibility report: **24 patterns analyzed**, flagged by severity
7. Show ora2pg complexity score: **B rating** (moderate complexity)

### Key Callout
> "Three tools independently assessed this database. MSSQL extension found 15 tables. ora2pg found 15 tables. DAB found 15 tables. They agree. That's the consensus gate."

---

## Scene 2: Multi-Tool Migration (4 minutes)

### Narration
> "Now the migration. pgLoader handles the data. But the stored procedures? That's where it gets interesting."

### Actions
1. Show pgLoader dry-run: type mappings validated (NVARCHAR->TEXT, BIT->BOOLEAN, etc.)
2. Show Copilot generating PL/pgSQL from extracted T-SQL
3. Show ora2pg independently converting the same SP
4. **Split screen:** Compare both outputs, merge the best
5. Show sqlfluff lint: 0 errors
6. Show pgtap test: PASS

### Key Callout
> "The cursor in this stored procedure? Copilot rewrote it as a CTE. ora2pg kept the cursor. sqlfluff flagged the cursor as an anti-pattern. We took Copilot's version. That's multi-tool consensus."

---

## Scene 3: Validation with Results (4 minutes)

### Narration
> "Migration is only as good as your validation. Here's where we prove it."

### Actions
1. Split screen: MSSQL extension on left (SQL Server), PG extension on right (PostgreSQL)
2. Run same query on both: identical results
3. Show row-count comparison: all tables match
4. Show pgtap tests: all green
5. Show HammerDB results: **PostgreSQL TPS matches or exceeds SQL Server**
6. Show EXPLAIN ANALYZE vs SSMS execution plan side-by-side

### Key Callout
> "The cursor rewrite in SP5? 10x faster on PostgreSQL. That's not just migration, that's modernization."

---

## Scene 4: The DAB Moment (2 minutes)

### Narration
> "Here's the moment that makes DBAs happy."

### Actions
1. Show DAB running on SQL Server: `GET /api/StockItems` returns JSON
2. Change ONE LINE: `database-type: postgresql`
3. Restart DAB
4. Hit same URL: **identical JSON from PostgreSQL**

### Key Callout
> "Applications don't even know the database changed. Same API, same data, different engine. Zero code changes."

---

## Scene 5: Security Proof (2 minutes)

### Narration
> "Before: plaintext connection strings, SQL logins, no audit. After..."

### Actions
1. Show sec-check before score: 4/10 tests pass
2. Show sec-check after score: **10/10 tests pass**
3. Show specific improvements:
   - Entra ID passwordless (no passwords anywhere)
   - pgAudit enabled (compliance logging)
   - Defender active (threat detection)
   - PUBLIC schema locked
   - RLS policies configured

### Key Callout
> "Every security test has a name, a pass criteria, and a result. This isn't 'trust me' - it's 'verify and prove'."

---

## Closing (60 seconds)

> "One Copilot prompt. Twelve tools. Tracked results. From a $15K/core/year SQL Server license to a zero-license PostgreSQL on Azure. Security went from 4/10 to 10/10. Performance improved. And the applications didn't change a single line of code."
>
> "This repo is yours. Clone it. Point it at your SQL Server. Run `/db-migrate`. See for yourself."

---

## Handling Questions

| Question | Response |
|---|---|
| "Does this work with our version?" | It's language-agnostic. Point it at any SQL Server 2016+. |
| "What about our complex SPs?" | ora2pg gives you a complexity score BEFORE you commit. No surprises. |
| "How accurate is the auto-conversion?" | Three tools convert independently. We take the consensus. sqlfluff and pgtap validate. |
| "What about SSIS/SSRS?" | This covers the database layer. SSIS/SSRS are separate workstreams. |
| "Can we do this gradually?" | DAB abstracts the database. Run both simultaneously during transition. |
