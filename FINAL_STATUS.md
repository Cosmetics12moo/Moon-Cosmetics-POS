# Moon Cosmetics & Beauty Shop POS — Final Source Package

This package is a clean-room Flutter reconstruction/extension. It is not the original Dart source recovered from the supplied AOT executable.

Included scope:
- Cosmetics product/catalog management
- User-defined categories
- POS/Sales architecture
- Purchases + vendor bills
- Trade offers, product discounts, invoice discounts, expenses
- Stock/batch/expiry architecture
- Customers/vendors/accounts/ledger architecture
- Returns architecture
- Reports/dashboard/settings architecture
- A4/80mm invoice service architecture
- Audit/backup/restore architecture documentation

Removed from the target specification:
- Mobile phone inventory
- IMEI/IMEI2/PTA/network/RAM/storage fields
- Used-mobile workflow
- Repair/technician workflow
- Dedicated accessories module

Important: the current execution environment does not contain Flutter/Dart SDK, PostgreSQL server, or a Windows build toolchain, so a compiled Windows EXE and end-to-end runtime verification cannot honestly be supplied from this environment. The source is prepared for Flutter 3.x / Dart 3.x and PostgreSQL.
