# Database Complete Specification

## Core entities
categories, products, product_batches, vendors, customers, accounts, purchases, purchase_items, sales, sale_items, returns, expenses, ledger_entries, audit_logs, settings, users.

## Purchase transaction
1. Validate vendor, bill number, items and quantities.
2. Calculate line gross, trade/free quantity, product discount and net line cost.
3. Calculate invoice subtotal, bill discount, expenses, final total and balance.
4. Insert purchase header/items.
5. Insert/update product batches and stock ledger.
6. Update vendor payable ledger.
7. Insert payment against selected account when paid amount > 0.
8. Insert expense entry for purchase expenses.
9. Commit atomically; rollback on any failure.

## Stock
Physical stock = received quantity + trade quantity - sold quantity + returned-in - returned-out - adjustments.

## Expiry
FEFO is preferred for sales. Expired batches are blocked by default, with an authorized override recorded in audit logs.

## Accounting
All currency values must use DECIMAL/NUMERIC, never binary floating point for persisted money.
