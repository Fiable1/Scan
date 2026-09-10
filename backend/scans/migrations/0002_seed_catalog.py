from django.db import migrations


SEED_CATALOG = [
    {'code': '9780199386429', 'title': 'New Oxford Primary Mathematics 6', 'author': 'Various', 'grade': 'Primary 6', 'category': 'Mathematics', 'isbn': '9780199386429', 'publisher': 'Oxford University Press', 'language': 'English'},
    {'code': '9780582312104', 'title': 'Longman English Workbook 6', 'author': 'Pearson', 'grade': 'Primary 6', 'category': 'English', 'isbn': '9780582312104', 'publisher': 'Pearson', 'language': 'English'},
    {'code': '9780435892258', 'title': 'Integrated Science Learner Book 6', 'author': 'REB', 'grade': 'Primary 6', 'category': 'Science', 'isbn': '9780435892258', 'publisher': 'REB', 'language': 'English'},
    {'code': '9780999577302', 'title': 'Indimu yose 6', 'author': 'REB', 'grade': 'Primary 6', 'category': 'Kinyarwanda', 'isbn': '9780999577302', 'publisher': 'REB', 'language': 'Kinyarwanda'},
    {'code': '9780198390022', 'title': 'Social Studies Learner Book 6', 'author': 'Longman', 'grade': 'Primary 6', 'category': 'Social Studies', 'isbn': '9780198390022', 'publisher': 'Longman', 'language': 'English'},
    {'code': '9780582312098', 'title': 'New Longman Science for Primary 5', 'author': 'Longman', 'grade': 'Primary 5', 'category': 'Science', 'isbn': '9780582312098', 'publisher': 'Longman', 'language': 'English'},
    {'code': '9780199386415', 'title': 'Oxford English for Primary 4', 'author': 'Oxford University Press', 'grade': 'Primary 4', 'category': 'English', 'isbn': '9780199386415', 'publisher': 'Oxford University Press', 'language': 'English'},
    {'code': '9781408846266', 'title': 'Grade 6 Mathematics Pupils Book', 'author': 'REB', 'grade': 'Primary 6', 'category': 'Mathematics', 'isbn': '9781408846266', 'publisher': 'REB', 'language': 'English'},
]


def seed_catalog(apps, schema_editor):
    BookCatalog = apps.get_model('scans', 'BookCatalog')
    for item in SEED_CATALOG:
        BookCatalog.objects.get_or_create(code=item['code'], defaults=item)


class Migration(migrations.Migration):

    dependencies = [
        ('scans', '0001_initial'),
    ]

    operations = [
        migrations.RunPython(seed_catalog, migrations.RunPython.noop),
    ]
