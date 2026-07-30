-- ============================================================
-- supplier_account + prod_supplier_due (mirror customer account)
-- bill_type: 5=purchase, 6=supplier collection, 7=supplier advance, 8=purchase return, 12=supplier old balance add
-- ============================================================
CREATE TABLE IF NOT EXISTS supplier_account (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    advance     DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    balance     DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    UNIQUE KEY uq_supplier (supplier_id),
    FOREIGN KEY (supplier_id) REFERENCES prod_supplier(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS prod_supplier_due (
    id          INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    amount      DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    cash_paid   DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    bank_paid   DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    balance     DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    pay_mode    TINYINT NOT NULL DEFAULT 1,
    pay_type    TINYINT NOT NULL DEFAULT 0,
    txn_type    VARCHAR(20) NOT NULL DEFAULT 'COLLECTION',
    notes       VARCHAR(255) DEFAULT NULL,
    uid         INT NOT NULL,
    date        DATE NOT NULL,
    time        TIME NOT NULL,
    INDEX idx_supplier (supplier_id),
    INDEX idx_txn_type (txn_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO supplier_account (supplier_id, advance, balance)
SELECT id, 0.00, 0.00 FROM prod_supplier
WHERE id NOT IN (SELECT supplier_id FROM supplier_account);
