-- ============================================================
-- Customer account transactions — type for prod_bill_due
-- Run once on MySQL
-- ============================================================
ALTER TABLE prod_bill_due
  ADD COLUMN txn_type VARCHAR(20) NOT NULL DEFAULT 'COLLECTION' AFTER pay_type;

ALTER TABLE prod_bill_due
  ADD COLUMN notes VARCHAR(255) DEFAULT NULL AFTER txn_type;

UPDATE prod_bill_due SET txn_type = 'COLLECTION' WHERE txn_type IS NULL OR txn_type = '';
