# Sales Pitch: SQL Server to PostgreSQL Migration - DBA Persona

## The Problem Every DBA Knows

> "I manage 200 SQL Server databases. Licensing costs are through the roof. My team is drowning in manual migration estimates. And every time someone says 'just move to Postgres', I think about the 6-12 months of stored procedure rewrites, the weekend cutovers, and the prayer that nothing breaks."

---

## Why DBAs Should Care

### The Cost Problem

| | SQL Server Enterprise | Azure PG Flexible Server |
|---|---|---|
| **License** | $15K+ per core/year | $0 (open source) |
| **Azure hosting** (2 vCPU, 8GB) | ~$400/mo (SQL MI) | ~$120/mo (GP D2s_v3) |
| **HA** | Always On AG (complex) | Built-in zone-redundant HA |
| **Auth** | SQL logins + AD (mixed) | Entra ID passwordless (modern) |
| **Audit** | SQL Server Audit (config heavy) | pgAudit extension (simple) |
| **Security** | Defender for SQL | Defender for Open-Source DBs |

**Result:** 60-80% cost reduction on database compute alone.

### The Risk Problem

Traditional migration approach:
- One DBA manually reads stored procedures
- One tool does the schema conversion
- Fingers crossed during cutover weekend
- 6-12 months of validation "is this right?"

**Our approach: Multi-tool redundancy**
- 12 tools independently validate every step
- No single tool decides the outcome
- Automated iteration until all tools agree
- Tracked performance and security metrics across iterations

### The Skills Problem

> "My team knows T-SQL, not PL/pgSQL."

Solution:
- **ora2pg** auto-converts stored procedures (DBA reviews, doesn't write)
- **Copilot** generates PL/pgSQL with explanations
- **sqlfluff** catches syntax errors before they hit the DB
- **pgtap** proves the migrated functions work identically
- **DAB** abstracts the database so apps don't even see the change

---

## The Demo in 5 Minutes

### Scene 1: Assessment (60 seconds)
```
/db-migrate samples/wide-world-importers
```
Copilot connects to SQL Server, discovers 15+ tables, 30+ stored procedures, flags 24 T-SQL incompatible patterns with severity ratings.

### Scene 2: Migration (90 seconds)
pgLoader transfers data. Copilot + ora2pg translate stored procedures. sqlfluff lints. Side-by-side: T-SQL on left, PL/pgSQL on right.

### Scene 3: Validation (90 seconds)
Split screen: MSSQL extension on SQL Server, PG extension on PostgreSQL. Same queries, same results. pgtap tests all green. HammerDB shows TPS improvement.

### Scene 4: The Aha Moment (30 seconds)
DAB running on SQL Server: `GET /api/StockItems` returns JSON.
Change ONE LINE in config: `database-type: postgresql`.
Same URL, same JSON. Apps don't know the database changed.

### Scene 5: Security Proof (30 seconds)
Before: plaintext connection strings, no audit logging, SQL logins.
After: Entra ID passwordless, pgAudit enabled, Defender active. 10/10 security tests pass.

---

## Value Metrics

| Metric | Before | After |
|---|---|---|
| Database license cost | $15K+/core/year | $0 |
| Monthly compute (2 vCPU) | ~$400 | ~$120 |
| Migration timeline | 6-12 months manual | Hours with agent |
| Validation confidence | "I hope it works" | 12-tool consensus |
| Security posture | 4/10 tests pass | 10/10 tests pass |
| SP unit testability | 0 tests | pgtap test per function |
| Performance tracking | Ad-hoc | Timestamped JSON trending |

---

## Handling DBA Objections

| Objection | Response |
|---|---|
| "Our SPs are too complex" | ora2pg gives you a complexity score (A/B/C) BEFORE you commit. No surprises. |
| "What about HIERARCHYID?" | We flag it as HIGH severity, provide ltree migration path, and test it. |
| "I don't trust automated conversion" | Neither do we. That's why 3 tools independently convert and cross-validate. |
| "What about performance?" | HammerDB runs same TPC-C on both. We _prove_ PG performs equal or better. |
| "My team doesn't know Postgres" | DAB abstracts the database. Your team uses the same REST/GraphQL API regardless of backend. |
| "What about our reporting?" | Optional Fabric integration: PG data auto-mirrors to OneLake for Power BI. |

---

## After the Demo: Next Steps

1. **Share the repo** - SSE can run `/db-migrate` on their own SQL Server instance
2. **Propose a pilot** - Pick one non-prod database, run the full pipeline, show results
3. **Quantify the opportunity** - 200 SQL Server DBs x $15K/core = $3M+/year in licensing alone
4. **Connect to Azure PG Flexible Server trial** - Free tier for evaluation
