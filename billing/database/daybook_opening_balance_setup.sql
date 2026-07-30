-- ============================================================
-- Day Book — Manual Opening Balance
-- Run once on your MySQL database
-- ============================================================
CREATE TABLE IF NOT EXISTS daybook_opening_balance (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    balance_date  DATE NOT NULL,
    amount        DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    notes         VARCHAR(255) DEFAULT NULL,
    uid           INT DEFAULT NULL,
    entry_date    DATE NOT NULL,
    entry_time    TIME NOT NULL,
    is_active     TINYINT(1) NOT NULL DEFAULT 1,
    INDEX idx_balance_date (balance_date),
    INDEX idx_active_date (is_active, balance_date)
);

-- bill_type 11 = opening balance (daybook_opening_balance.id)
-- Run database/prod_ledger_setup.sql if prod_ledger table is missing.
