# DEMO SCRIPT: SQL Server to PostgreSQL Migration

**Audience:** SSEs, DBAs, Engineering Leaders
**Duration:** 15-20 minutes
**Persona:** Senior DBA managing 200+ SQL Server databases

---

## Pre-Demo Setup (Do This BEFORE the Demo)

> Complete these steps ahead of time so everything is connected and ready when the demo starts.

### Step 1: Start Local Databases

Open a **PowerShell terminal** in VS Code:

1. Press **Ctrl+`** (backtick) to open the VS Code integrated terminal
2. Make sure you're in the repo root folder. The prompt should show something like:
   ```
   PS C:\Users\krfolkes\aiapps\devloper-persona-demo-dba\sql-to-postgres-migration>
   ```
   If not, run: `cd "c:\Users\krfolkes\aiapps\devloper-persona-demo-dba\sql-to-postgres-migration"`
3. Run the one-click setup script:
   ```powershell
   .\scripts\setup-local-env.ps1
   ```
4. Wait for it to finish. You should see:
   ```
   =============================================
     Local Environment Ready!
   =============================================

     SQL Server:  localhost,1433  |  sa / Str0ngP@ssw0rd!  |  DB: WideWorldImporters
     PostgreSQL:  localhost:5432  |  wwi_user / Str0ngP@ssw0rd!  |  DB: wide_world_importers
   ```
5. Verify containers are running:
   ```powershell
   docker compose ps
   ```
   Both `wwi-sqlserver` and `wwi-postgres` should show status **"healthy"**.

### Step 2: Connect the MSSQL Extension (SQL Server)

1. **Open the SQL Server sidebar:**
   - Look at the left side of VS Code for the icon bar (vertical strip of icons)
   - Click the **SQL Server icon** (looks like a cylinder/database — it says "SQL Server" when you hover)
   - OR press **Ctrl+Shift+P** → type `MSSQL: Connect` → press Enter

2. **Create a new connection:**
   - In the SQL Server sidebar panel, click the **"+" button** at the top (tooltip: "Add Connection")
   - A connection dialog will appear at the top of VS Code

3. **Fill in connection details:**
   - **Server name:** `localhost,1433` (type this, then press Enter)
   - **Database name:** `WideWorldImporters` (type this, then press Enter)
   - **Authentication Type:** Select **"SQL Login"** from the dropdown
   - **User name:** `sa` (type this, then press Enter)
   - **Password:** `Str0ngP@ssw0rd!` (type this, then press Enter)
   - **Save Password?:** Select **"Yes"**
   - **Profile Name:** `WWI-Local-Docker` (type this, then press Enter)

4. **Verify the connection:**
   - In the SQL Server sidebar, you should now see **"WWI-Local-Docker"** listed
   - Click the **arrow (▶)** next to it to expand
   - You should see: `WideWorldImporters` → `Tables` → all the tables (Application.Cities, Sales.Orders, Warehouse.StockItems, etc.)
   - If you see the tables, **SQL Server is connected!**

### Step 3: Connect the PostgreSQL Extension (Microsoft)

> **Required extension:** `ms-ossdata.vscode-pgsql` ("PostgreSQL" by Microsoft). If not installed, press **Ctrl+Shift+X** → search `ms-ossdata.vscode-pgsql` → click **Install**.

1. **Open the PostgreSQL sidebar:**
   - Look at the left icon bar for the **PostgreSQL icon** (elephant logo — says "PostgreSQL" on hover)
   - Click it to open the PostgreSQL Explorer panel
   - OR press **Ctrl+Shift+P** → type `PGSQL: New Connection` → press Enter

2. **A connection dialog panel will appear.** Fill in the fields exactly as shown:
   - **SERVER NAME:** `localhost` (**not** the display name — this must be the actual hostname)
   - **AUTHENTICATION TYPE:** `Password` (select from dropdown)
   - **USER NAME:** `wwi_user`
   - **PASSWORD:** `Str0ngP@ssw0rd!`
   - **SAVE PASSWORD:** check the box ☑
   - **DATABASE NAME:** `wide_world_importers` (type it or select from dropdown)
   - **CONNECTION NAME:** `WWI-Postgres-Docker` (this is your friendly label — goes at the bottom)
   - Leave **SERVER GROUP** as `Servers` (default)

   > ⚠️ **Common mistake:** Do NOT put `WWI-Postgres-Docker` in the SERVER NAME field. That field must be `localhost`. The CONNECTION NAME field at the bottom is where the friendly label goes.

3. **Click "Save & Connect"** (blue button at the bottom of the dialog)

4. **Verify the connection:**
   - In the PostgreSQL sidebar, you should see **"WWI-Postgres-Docker"** listed under Servers
   - Click the **arrow (▶)** next to it to expand
   - Navigate: `Databases` → `wide_world_importers` → `Schemas` → you should see: `application`, `integration`, `purchasing`, `sales`, `sequences`, `warehouse`, `website`
   - These schemas are empty right now (that's expected — the migration will populate them)
   - If you see the schemas, **PostgreSQL is connected!**

### Step 4: Verify Both Connections Work

1. **Test SQL Server — run a query:**
   - In the SQL Server sidebar, right-click on **"WideWorldImporters"** → select **"New Query"**
   - A new SQL editor tab opens. Type:
     ```sql
     SELECT TOP 5 StockItemName, UnitPrice FROM Warehouse.StockItems ORDER BY UnitPrice DESC;
     ```
   - Press **Ctrl+Shift+E** (or click the green **▶ Run** button at the top) to execute
   - You should see 5 rows of stock item names and prices in the results panel below

2. **Test PostgreSQL — run a query:**
   - In the PostgreSQL sidebar, right-click on **"wide_world_importers"** (under your connection) → select **"New Query"**
   - A new SQL editor tab opens. Type:
     ```sql
     SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT IN ('pg_catalog','information_schema','pg_toast') ORDER BY schema_name;
     ```
   - Press **F5** to execute (or right-click in the editor → **Run Query**)
   - You should see 8 schemas listed (application, integration, public, purchasing, sales, sequences, warehouse, website)

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

1. **Show VS Code is open with this repo:**
   - The Explorer sidebar (first icon, top-left) should show the folder tree rooted at `sql-to-postgres-migration`

2. **Open Copilot Chat:**
   - Click the **Copilot icon** in the left sidebar (sparkle/star icon, usually near the bottom of the icon bar)
   - OR press **Ctrl+Shift+I** to open the Copilot Chat panel
   - The chat panel opens on the right side of VS Code

3. **Run the migration prompt:**
   - In the Copilot Chat input box at the bottom, type exactly:
     ```
     /db-migrate samples/wide-world-importers
     ```
   - Press **Enter**
   - Copilot will start the multi-phase migration agent

4. **Show MSSQL extension connecting to SQL Server:**
   - Click the **SQL Server icon** in the left sidebar
   - Expand **WWI-Local-Docker** → **WideWorldImporters** → **Tables**
   - Point out the table list: `Application.Cities`, `Application.Countries`, `Sales.Customers`, `Sales.Orders`, `Warehouse.StockItems`, etc.
   - Say: *"The MSSQL extension discovered 48 tables including temporal archive tables"*

5. **Show the T-SQL incompatibility report:**
   - In the Explorer sidebar (Ctrl+Shift+E), navigate to: **docs** → double-click **tsql-incompatibility-report.md**
   - Full path: `docs/tsql-incompatibility-report.md`
   - Scroll to show the three severity tables (HIGH / MEDIUM / LOW)
   - Point out: *"24 patterns analyzed. 3 HIGH severity patterns found: cursors, MERGE statements, and GEOGRAPHY columns."*

6. **Show the source assessment:**
   - In Explorer, navigate to: **docs** → double-click **01-source-assessment.md**
   - Full path: `docs/01-source-assessment.md`
   - Scroll to the "ora2pg Complexity Score" section
   - Point out the **B rating** (moderate complexity)

### Key Callout
> "Three tools independently assessed this database. MSSQL extension found the tables. ora2pg scored it a B. DAB discovered the same entities. They agree. That's the consensus gate."

---

## Scene 2: Multi-Tool Migration (4 minutes)

### Narration
> "Now the migration. pgLoader handles the data. But the stored procedures? That's where it gets interesting."

### Actions

1. **Show the pgLoader config with type mappings:**
   - In Explorer, navigate to: **samples** → **wide-world-importers** → **migration-scripts** → double-click **pgloader.conf**
   - Full path: `samples/wide-world-importers/migration-scripts/pgloader.conf`
   - Scroll to the `CAST` section — point out: `nvarchar → text`, `bit → boolean`, `datetime2 → timestamptz`, `geography → text`

2. **Show Copilot-generated PL/pgSQL translations:**
   - In Explorer, navigate to: **samples** → **wide-world-importers** → **migration-scripts** → **tsql-to-plpgsql**
   - Full path: `samples/wide-world-importers/migration-scripts/tsql-to-plpgsql/`
   - Double-click **sp_insert_customer_order.pgsql** — this is the most complex translation
   - Point out the comment block at the top: *"Cursor → CTE, MERGE → INSERT ON CONFLICT, OUTPUT → RETURNING"*
   - Scroll to the `jsonb_array_elements()` call — say: *"The cursor is gone. This is set-based now."*

3. **Show the ora2pg comparison:**
   - Open the **README.md** in the same `tsql-to-plpgsql/` folder
   - Full path: `samples/wide-world-importers/migration-scripts/tsql-to-plpgsql/README.md`
   - Scroll to the "Key Decisions" table at the bottom
   - Point out: *"Copilot used a CTE — ora2pg kept the cursor. sqlfluff flagged the cursor. We took Copilot's version."*

4. **Show the schema optimization reasoning:**
   - In Explorer, navigate to: **docs** → double-click **schema-optimization-logic.md**
   - Full path: `docs/schema-optimization-logic.md`
   - Scroll to "Stored Procedure Optimizations" table
   - Point out the "10x faster" note on cursor-based processing

5. **Show the migration execution report:**
   - In Explorer, navigate to: **docs** → double-click **02-migration-execution.md**
   - Full path: `docs/02-migration-execution.md`
   - Scroll to "sqlfluff Lint Results" — show 0 violations
   - Scroll to "pgtap Test Results" — show all tests passing

### Key Callout
> "The cursor in this stored procedure? Copilot rewrote it as a CTE. ora2pg kept the cursor. sqlfluff flagged the cursor as an anti-pattern. We took Copilot's version. That's multi-tool consensus."

---

## Scene 3: Validation with Results (4 minutes)

### Narration
> "Migration is only as good as your validation. Here's where we prove it."

### Actions

1. **Split screen — SQL Server query on left, PostgreSQL on right:**
   - In the SQL Server sidebar (left icon bar → SQL Server icon), right-click **WideWorldImporters** → **New Query**
   - A SQL tab opens. Type:
     ```sql
     SELECT TOP 5 StockItemName, UnitPrice FROM Warehouse.StockItems ORDER BY UnitPrice DESC;
     ```
   - Run it with **Ctrl+Shift+E** — show results
   - Now drag that tab to the left half of the editor (or right-click tab → "Split Right")
   - Press **Ctrl+Shift+P** → `PostgreSQL: New Query` → select **WWI-Postgres-Docker**
   - In the new tab (right side), type the PostgreSQL equivalent:
     ```sql
     SELECT stock_item_name, unit_price FROM warehouse.stock_items ORDER BY unit_price DESC LIMIT 5;
     ```
   - Run it — show identical results side by side

2. **Show the row-count comparison query:**
   - In Explorer, navigate to: **tests** → **row-count-comparison** → double-click **compare.sql**
   - Full path: `tests/row-count-comparison/compare.sql`
   - Point out: *"This query runs on both databases. Every table must match."*

3. **Show pgtap test files:**
   - In Explorer, navigate to: **tests** → **pgtap** → **t**
   - Full path: `tests/pgtap/t/`
   - Double-click **003-business-logic.sql** — show the test that verifies stock can't go below zero
   - Say: *"This test proves the business rule survived migration."*

4. **Show the validation report:**
   - In Explorer, navigate to: **docs** → double-click **03-validation-report.md**
   - Full path: `docs/03-validation-report.md`
   - Scroll to "Performance (Before/After)" table
   - Point out perf-005: *"85ms on SQL Server, 8.3ms on PostgreSQL. The cursor rewrite gave us a 10x improvement."*

5. **Show the performance trending:**
   - In Explorer, navigate to: **tests** → **performance** → **results** → double-click **trending.md**
   - Full path: `tests/performance/results/trending.md`
   - Show the bar chart comparing SQL Server vs PostgreSQL execution times

### Key Callout
> "The cursor rewrite in SP5? 10x faster on PostgreSQL. That's not just migration, that's modernization."

---

## Scene 4: The DAB Moment (2 minutes)

### Narration
> "Here's the moment that makes DBAs happy."

### Actions

1. **Show the SQL Server DAB config:**
   - In Explorer, navigate to: **dab** → double-click **dab-config-sqlserver.json**
   - Full path: `dab/dab-config-sqlserver.json`
   - Point out line 3: `"database-type": "mssql"`
   - Point out the entities: StockItems, Suppliers, Customers, Orders, PurchaseOrders

2. **Show the PostgreSQL DAB config:**
   - In Explorer, double-click **dab-config-postgres.json** (same `dab/` folder)
   - Full path: `dab/dab-config-postgres.json`
   - Point out line 3: `"database-type": "postgresql"`
   - Point out: the entity names changed (`Warehouse.StockItems` → `warehouse.stock_items`) but the REST/GraphQL API paths are identical

3. **The demo moment:**
   - Say: *"Same API endpoint. Same JSON response. The only thing that changed is one line — the database type. Applications don't even know the database changed."*

### Key Callout
> "Applications don't even know the database changed. Same API, same data, different engine. Zero code changes."

---

## Scene 5: Security Proof (2 minutes)

### Narration
> "Before: plaintext connection strings, SQL logins, no audit. After..."

### Actions

1. **Show the security test suite:**
   - In Explorer, navigate to: **tests** → **security** → **t**
   - Full path: `tests/security/t/`
   - You'll see 10 test files: `sec-001-no-plaintext-creds.sql` through `sec-010-defender-enabled.sql`
   - Double-click **sec-001-no-plaintext-creds.sql** — show the test logic
   - Double-click **sec-006-no-public-schema-grants.sql** — show the PUBLIC schema lockdown test

2. **Show the security results in the validation report:**
   - Open **docs/03-validation-report.md** (if not already open — it's in the `docs/` folder)
   - Full path: `docs/03-validation-report.md`
   - Scroll to "4. Security (Before/After)" section
   - Point out: every row went from FAIL → **PASS**
   - Score: **4/10 → 10/10**

3. **Point out specific improvements:**
   - Entra ID passwordless (sec-001: no passwords in code)
   - pgAudit enabled (sec-003: compliance logging)
   - Defender active (sec-010: threat detection)
   - PUBLIC schema locked (sec-006: `REVOKE CREATE ON SCHEMA public`)
   - RLS policies configured (sec-005: row-level security on PII tables)

### Key Callout
> "Every security test has a name, a pass criteria, and a result. This isn't 'trust me' — it's 'verify and prove'."

---

## Closing (60 seconds)

> "One Copilot prompt. Twelve tools. Tracked results. From a $15K/core/year SQL Server license to a zero-license PostgreSQL on Azure. Security went from 4/10 to 10/10. Performance improved. And the applications didn't change a single line of code."
>
> "This repo is yours. Clone it. Point it at your SQL Server. Run `/db-migrate`. See for yourself."

---

## Quick Reference: Key File Locations

| What | Where to Find It | Full Path |
|---|---|---|
| Migration prompt | Copilot Chat | Type `/db-migrate samples/wide-world-importers` |
| Source assessment | Explorer → docs folder | `docs/01-source-assessment.md` |
| T-SQL incompatibility report | Explorer → docs folder | `docs/tsql-incompatibility-report.md` |
| Migration execution report | Explorer → docs folder | `docs/02-migration-execution.md` |
| Schema optimization reasoning | Explorer → docs folder | `docs/schema-optimization-logic.md` |
| Validation report | Explorer → docs folder | `docs/03-validation-report.md` |
| Performance trending | Explorer → tests → performance → results | `tests/performance/results/trending.md` |
| pgLoader config | Explorer → samples → wide-world-importers → migration-scripts | `samples/wide-world-importers/migration-scripts/pgloader.conf` |
| PL/pgSQL translations | Explorer → samples → wide-world-importers → migration-scripts → tsql-to-plpgsql | `samples/wide-world-importers/migration-scripts/tsql-to-plpgsql/` |
| pgtap tests | Explorer → tests → pgtap → t | `tests/pgtap/t/001-schema.sql`, `002-functions.sql`, `003-business-logic.sql` |
| Security tests | Explorer → tests → security → t | `tests/security/t/sec-001-*.sql` through `sec-010-*.sql` |
| DAB config (SQL Server) | Explorer → dab folder | `dab/dab-config-sqlserver.json` |
| DAB config (PostgreSQL) | Explorer → dab folder | `dab/dab-config-postgres.json` |
| Row-count comparison | Explorer → tests → row-count-comparison | `tests/row-count-comparison/compare.sql` |
| Docker containers | Terminal | `docker compose ps` |

---

## Handling Questions

| Question | Response |
|---|---|
| "Does this work with our version?" | It's language-agnostic. Point it at any SQL Server 2016+. |
| "What about our complex SPs?" | ora2pg gives you a complexity score BEFORE you commit. No surprises. |
| "How accurate is the auto-conversion?" | Three tools convert independently. We take the consensus. sqlfluff and pgtap validate. |
| "What about SSIS/SSRS?" | This covers the database layer. SSIS/SSRS are separate workstreams. |
| "Can we do this gradually?" | DAB abstracts the database. Run both simultaneously during transition. |

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `docker compose up` fails | Make sure Docker Desktop is running (system tray icon). Try: `docker info` in terminal. |
| SQL Server won't connect | Check container is running: `docker compose ps`. Password is `Str0ngP@ssw0rd!` (capital S, zero not O). |
| PostgreSQL won't connect | Check container health: `docker exec wwi-postgres pg_isready`. Port is `5432`. |
| MSSQL extension doesn't show tables | Click the refresh icon (circular arrow) in the SQL Server sidebar. Or disconnect/reconnect the profile. |
| PostgreSQL extension doesn't show schemas | Refresh the connection. Ensure you selected database `wide_world_importers` (not `postgres`). |
| `/db-migrate` doesn't work | Make sure GitHub Copilot extension is installed and you're signed in. Check that `.github/prompts/db-migrate.prompt.md` exists. |
| Backup download is slow | The .bak file is ~120MB. It's cached in `./data/` after first download. |
| Want to start fresh | Run `docker compose down -v` to delete everything, then `.\scripts\setup-local-env.ps1` again. |
