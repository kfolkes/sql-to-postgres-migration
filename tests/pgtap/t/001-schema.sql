-- 001-schema: Verify migrated schema exists
BEGIN;
SELECT plan(5);

SELECT has_schema('warehouse', 'Schema warehouse should exist');
SELECT has_schema('purchasing', 'Schema purchasing should exist');
SELECT has_schema('sales', 'Schema sales should exist');
SELECT has_schema('application', 'Schema application should exist');

SELECT has_table('warehouse', 'stock_items', 'Table warehouse.stock_items should exist');

SELECT * FROM finish();
ROLLBACK;
