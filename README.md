# Rwanda School Book Scanner

Professional Flutter + Django application for **Rwandan school librarians**.

## Final workflow
1. Librarian logs in or registers under a Rwandan school.
2. Scan the barcode/ISBN of **each physical book**.
3. Capture the cover photo.
4. Look up book metadata using the scanned code.
5. Save title, author, grade/level, ISBN, category, publisher and other available metadata.
6. Every physical scan is recorded as an individual row.
7. The backend immediately updates the Excel workbook.
8. View all scans, analytics and download the complete Excel file.

> There is deliberately **no copies/quantity field**. Each physical book is scanned and recorded independently.

## Run backend
```bash
cd backend
python -m venv .venv
# Windows: .venv\\Scripts\\activate
# Linux/macOS: source .venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py seed_schools
python manage.py runserver 0.0.0.0:8000
```

## Run Flutter
```bash
cd app
flutter pub get
flutter run
```

Set the backend URL in the app. Android emulator default is `http://10.0.2.2:8000`.

## Main API
- `POST /api/auth/register/`
- `POST /api/auth/login/`
- `GET /api/schools/`
- `GET /api/books/lookup/?code=...`
- `POST /api/scans/` (multipart; includes `cover`)
- `GET /api/scans/list/`
- `GET /api/analytics/`
- `GET /api/scans/excel/`
