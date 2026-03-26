# Migration Flow Architecture

End-to-end Mermaid diagrams for the SQL Server to PostgreSQL migration pipeline.

## Overall Migration Pipeline

```mermaid
flowchart TB
    subgraph P0["Phase 0: Precheck"]
        V0[Verify 12 tools available]
    end
    
    subgraph P1["Phase 1: Assessment"]
        direction LR
        M1[MSSQL ext\nSchema Discovery]
        O1[ora2pg\nComplexity Score]
        D1[DAB\nEntity Discovery]
        M1 & O1 & D1 --> CG1{Consensus\nGate}
        CG1 --> |All agree| A1[01-source-assessment.md]
        CG1 --> |Disagree| INV1[Investigate] --> M1
    end
    
    subgraph P2["Phase 2: Migration"]
        direction LR
        PGL[pgLoader\nDry Run + Transfer]
        ORA[ora2pg\nSP Conversion]
        COP[Copilot\nPL/pgSQL Gen]
        SQL[sqlfluff lint]
        PGT[pgtap tests]
        PGL --> SQL
        ORA & COP --> |Merge best| SQL --> PGT
        PGT --> CG2{Consensus\nGate}
        CG2 --> |All pass| A2[02-migration-execution.md]
        CG2 --> |Fail| FIX2[Fix + Re-run] --> SQL
    end
    
    subgraph P3["Phase 3: Validation"]
        direction LR
        RC[Row Counts]
        PT[pgtap Tests]
        DAB3[DAB API\nRegression]
        HDB[HammerDB\nTPC-C]
        SEC[sec-check\nDelta]
        RC & PT & DAB3 & HDB & SEC --> CG3{Consensus\nGate}
        CG3 --> |All pass| A3[03-validation-report.md]
        CG3 --> |Fail| OPT3[Optimize + Iterate] --> RC
    end
    
    P0 --> P1 --> P2 --> P3
    
    style CG1 fill:#2ecc71,color:#fff
    style CG2 fill:#2ecc71,color:#fff
    style CG3 fill:#2ecc71,color:#fff
```

## Tool Integration Map

```mermaid
flowchart LR
    subgraph MCP["MCP Servers"]
        GH[GitHub MCP\nRepo ops, issues, PRs]
        DABM[DAB MCP\nCRUD, describe_entities]
    end
    
    subgraph VSCE["VS Code Extensions"]
        MSSQL[MSSQL Extension\nmssql_connect\nmssql_list_tables\nmssql_run_query]
        PGSQL[PostgreSQL Extension\nTarget validation]
    end
    
    subgraph CLI["CLI Tools"]
        PGL[pgLoader]
        ORA[ora2pg]
        SQFL[sqlfluff]
        PGTAP[pgtap / pg_prove]
        HAMM[HammerDB]
        PGBN[pgbench]
        SCHECK[sec-check / agentsec]
        DABCLI[DAB CLI]
    end
    
    subgraph AZURE["Azure Services"]
        PGFS[Azure PG\nFlexible Server]
        DFND[Defender for\nOpen-Source DBs]
        ENTRA[Entra ID\nPasswordless]
        PREMIG[Premigration\nValidation]
    end
    
    subgraph IDE["SSMS 22"]
        PLANS[Execution Plans]
        HINTS[Query Hint\nRecommendation]
        LIVE[Live Query\nStatistics]
    end
    
    COPILOT[GitHub Copilot\nAgent Orchestrator] --> MCP & VSCE & CLI
    CLI --> AZURE
    IDE --> |Baseline| COPILOT
    
    style COPILOT fill:#6f42c1,color:#fff
    style PGFS fill:#336791,color:#fff
```

## Iteration Feedback Loop

```mermaid
flowchart TB
    START[Run Migration] --> TEST[Run All Tests]
    TEST --> CHECK{All 20 tests\npass?}
    CHECK --> |No| ANALYZE[Analyze Failures]
    ANALYZE --> CATS{Category?}
    CATS --> |Performance| PERF[Add indexes\nRewrite cursors\nEnable PgBouncer]
    CATS --> |Security| SECU[Enable pgAudit\nLock PUBLIC schema\nAdd RLS policies]
    CATS --> |Functional| FUNC[Fix PL/pgSQL\nUpdate pgtap tests]
    CATS --> |Data| DATA[Rerun pgLoader\nFix type mappings]
    PERF & SECU & FUNC & DATA --> RERUN[Re-run Tests\nSave JSON Results]
    RERUN --> TEST
    CHECK --> |Yes| DONE[Migration\nValidated]
    DONE --> TREND[Generate\nTrending Report]
    
    style DONE fill:#2ecc71,color:#fff
    style CHECK fill:#f39c12,color:#fff
```
