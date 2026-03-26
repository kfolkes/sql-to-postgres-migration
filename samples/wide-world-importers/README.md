# WideWorldImporters Sample Database

Microsoft's official SQL Server sample database used as the demo target for this migration accelerator.

## Download

- **Full backup (.bak):** [aka.ms/WideWorldImporters](https://aka.ms/WideWorldImporters)
- **Source repo:** [microsoft/sql-server-samples](https://github.com/microsoft/sql-server-samples/tree/master/samples/databases/wide-world-importers)

## Database Profile

| Property | Value |
|---|---|
| Schemas | Application, Purchasing, Sales, Warehouse |
| Tables | 15+ (with temporal/system-versioned) |
| Stored Procedures | 30+ |
| Views | 10+ |
| Triggers | Multiple (temporal table maintenance) |
| Special Types | HIERARCHYID, GEOGRAPHY, JSON columns |
| Database Size | ~120 MB (full sample) |

## Why WideWorldImporters?

Ideal for DBA migration demos because it contains:
- **Complex stored procedures** with business logic
- **Temporal tables** (system-versioned) that require special migration handling
- **HIERARCHYID** columns that have no direct PostgreSQL equivalent
- **GEOGRAPHY** columns requiring PostGIS
- **JSON columns** (custom fields stored as NVARCHAR(MAX) with JSON)
- **Multiple schemas** testing cross-schema migration

## Setup

```powershell
# Restore the backup
RESTORE DATABASE WideWorldImporters
FROM DISK = 'C:\path\to\WideWorldImporters-Full.bak'
WITH MOVE 'WWI_Primary' TO 'C:\data\WideWorldImporters.mdf',
     MOVE 'WWI_UserData' TO 'C:\data\WideWorldImporters_UserData.ndf',
     MOVE 'WWI_Log' TO 'C:\data\WideWorldImporters.ldf',
     MOVE 'WWI_InMemory_Data_1' TO 'C:\data\WideWorldImporters_InMemory.ndf';
```
