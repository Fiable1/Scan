import os
from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')

# Ensure database schema + seed data exist before serving (idempotent, guards
# against racing cold starts on serverless platforms like Vercel).
try:
    from django.db import connection
    from django.core.management import call_command
    call_command('migrate', interactive=False, verbosity=0)
    call_command('seed_catalog', verbosity=0)
except Exception:
    pass

application = get_wsgi_application()
