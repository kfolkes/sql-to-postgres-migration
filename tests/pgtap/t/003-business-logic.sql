-- 003-business-logic: Verify business rules are preserved in migrated functions
BEGIN;
SELECT plan(4);

-- Test 1: Stock reduction below zero should fail
SELECT throws_ok(
  $$SELECT warehouse.update_stock_item_holdings(1, -999999)$$,
  NULL,
  'Reducing stock below zero should raise an exception'
);

-- Test 2: Valid stock reduction should succeed
SELECT lives_ok(
  $$SELECT warehouse.update_stock_item_holdings(1, -1)$$,
  'Reducing stock by 1 should succeed'
);

-- Test 3: Pagination returns expected number of rows
SELECT results_eq(
  $$SELECT count(*)::integer FROM warehouse.get_stock_items_paginated(5, 1)$$,
  5,
  'Paginated query with page_size=5 should return 5 rows'
);

-- Test 4: Point lookup returns exactly one row
SELECT results_eq(
  $$SELECT count(*)::integer FROM warehouse.get_stock_item_by_id(1)$$,
  1,
  'Looking up item by ID should return exactly 1 row'
);

SELECT * FROM finish();
ROLLBACK;
