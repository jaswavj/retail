-- ============================================================
-- prod_ledger — unified transaction ledger
-- bill_type references bill_type table:
--   1 customer bill, 2 customer balance collection, 3 customer add advance,
--   4 customer old balance add, 5 purchase entry, 6 supplier balance collection,
--   7 supplier add advance, 8 purchase return, 9 expense entry, 11 opening balance, 12 supplier old balance add, ...
-- ============================================================
CREATE TABLE IF NOT EXISTS prod_ledger (
    id            INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    bill_type     INT NOT NULL COMMENT 'FK logical: bill_type.id',
    bill_id       INT NOT NULL DEFAULT 0 COMMENT 'Source row id e.g. prod_bill.id',
    customer_id   INT DEFAULT NULL,
    supplier_id   INT DEFAULT NULL,
    payment_mode  TINYINT NOT NULL DEFAULT 1 COMMENT '1=Cash 2=Bank 3=Mixed',
    bill_amount   DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    cash_paid     DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    bank_paid     DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    payment_type  TINYINT NOT NULL DEFAULT 0 COMMENT 'UPI, card, etc. from configure_payment_type',
    uid           INT NOT NULL,
    date_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_bill_type_id (bill_type, bill_id),
    INDEX idx_customer (customer_id),
    INDEX idx_supplier (supplier_id),
    INDEX idx_date_time (date_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
