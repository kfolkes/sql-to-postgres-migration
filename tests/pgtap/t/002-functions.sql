-- 002-functions: Verify migrated PL/pgSQL functions exist with correct signatures
BEGIN;
SELECT plan(3);

-- Verify key functions exist (adapt to your actual migrated functions)
SELECT has_function(
  'warehouse',
  'get_stock_items_paginated',
  ARRAY['integer', 'integer'],
  'Function get_stock_items_paginated(page_size, page_number) should exist'
);

SELECT has_function(
  'warehouse',
  'get_stock_item_by_id',
  ARRAY['integer'],
  'Function get_stock_item_by_id(item_id) should exist'
);

SELECT has_function(
  'warehouse',
  'update_stock_item_holdings',
  ARRAY['integer', 'integer'],
  'Function update_stock_item_holdings(item_id, quantity_change) should exist'
);

SELECT * FROM finish();
ROLLBACK;
