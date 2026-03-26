# T-SQL to PL/pgSQL Translations

This directory contains the PL/pgSQL translations of WideWorldImporters stored procedures.

Each file follows the naming convention:
- `sp_<original_name>.pgsql` - Translated function
- `sp_<original_name>.test.sql` - Corresponding pgtap test

## Translation Process

For each stored procedure:
1. **Copilot** generates initial PL/pgSQL from MSSQL ext source extraction
2. **ora2pg** auto-converts independently
3. **Merge** the best of both outputs
4. **sqlfluff** lint the result
5. **pgtap** test for functional equivalence
6. **Iterate** until sqlfluff AND pgtap pass

## Status

| Original SP | PL/pgSQL File | sqlfluff | pgtap | Status |
|---|---|---|---|---|
| *Populated during Phase 2* | | | | |
