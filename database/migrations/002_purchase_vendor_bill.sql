-- Purchase/vendor bill enhancement for Moon Cosmetics & Beauty Shop
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS bill_number VARCHAR(100);
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS payment_account_id VARCHAR(50) REFERENCES accounts(id);
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS bill_discount_percent NUMERIC(7,3) NOT NULL DEFAULT 0;
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS bill_discount_amount NUMERIC(12,2) NOT NULL DEFAULT 0;
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS expenses_percent NUMERIC(7,3) NOT NULL DEFAULT 0;
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS expenses_amount NUMERIC(12,2) NOT NULL DEFAULT 0;
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS subtotal NUMERIC(12,2) NOT NULL DEFAULT 0;
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS product_discount_amount NUMERIC(12,2) NOT NULL DEFAULT 0;
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS balance_amount NUMERIC(12,2) NOT NULL DEFAULT 0;
ALTER TABLE purchase_items ADD COLUMN IF NOT EXISTS trade_offer_percent NUMERIC(7,3) NOT NULL DEFAULT 0;
ALTER TABLE purchase_items ADD COLUMN IF NOT EXISTS trade_offer_quantity NUMERIC(12,3) NOT NULL DEFAULT 0;
ALTER TABLE purchase_items ADD COLUMN IF NOT EXISTS purchase_discount_percent NUMERIC(7,3) NOT NULL DEFAULT 0;
ALTER TABLE purchase_items ADD COLUMN IF NOT EXISTS purchase_discount_amount NUMERIC(12,2) NOT NULL DEFAULT 0;
ALTER TABLE purchase_items ADD COLUMN IF NOT EXISTS sale_price NUMERIC(12,2) NOT NULL DEFAULT 0;
ALTER TABLE purchase_items ADD COLUMN IF NOT EXISTS net_cost NUMERIC(12,2) NOT NULL DEFAULT 0;
CREATE INDEX IF NOT EXISTS idx_purchases_supplier_date ON purchases(supplier_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_purchases_bill_number ON purchases(bill_number);
CREATE INDEX IF NOT EXISTS idx_purchase_items_product ON purchase_items(product_id);
