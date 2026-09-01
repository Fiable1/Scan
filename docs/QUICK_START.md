# Quick Start

## 1. Backend
Open a terminal in `backend` and run:

```bash
python -m venv .venv
.venv\\Scripts\\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py seed_schools
python manage.py runserver 0.0.0.0:8000
```

## 2. Flutter
Install Flutter and Android Studio, then:

```bash
cd app
flutter pub get
flutter run
```

For a real Android phone on the same Wi-Fi, use the computer's LAN IP in Settings, for example `http://192.168.1.10:8000`.

## 3. First librarian
Use **Register**. Select one of the seeded Rwandan schools. The backend rejects schools that are not active Rwandan schools.
