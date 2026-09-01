# Implementation notes

## Individual scan rule
Every physical book produces a `BookScan` database row and an Excel row. The backend never increments a copies field and never merges scans.

## Automatic metadata
The `lookup` endpoint first checks the local catalog by barcode/code and ISBN. When a catalog match exists, metadata is returned to the Flutter app and also enforced server-side during saving if the client leaves fields empty.

## Excel rule
After every successful scan, `build_excel()` rebuilds the canonical workbook from the database. This avoids Excel/database drift and means the downloadable file always contains the full current scan list.

## Registration rule
Registration requires an active school whose country is Rwanda. The resulting account is a Librarian profile attached to that school.
