from pathlib import Path
from openpyxl import Workbook
from django.conf import settings
from .models import BookScan

HEADERS=['Title','Author','Grade / Level','ISBN','Barcode / Code','Category','Publisher','Language','Cover File','School','Librarian','Date Scanned','Time Scanned','Matched Catalog']

def build_excel():
    out=Path(settings.MEDIA_ROOT)/'excel'; out.mkdir(parents=True,exist_ok=True)
    path=out/'rwanda_school_book_scans.xlsx'
    wb=Workbook(); ws=wb.active; ws.title='Book Scans'; ws.append(HEADERS)
    for scan in BookScan.objects.select_related('school','librarian__user').order_by('scanned_at'):
        local=scan.scanned_at.astimezone()
        ws.append([scan.title,scan.author,scan.grade,scan.isbn,scan.code,scan.category,scan.publisher,scan.language,scan.cover.name if scan.cover else '',scan.school.name,scan.librarian.user.get_full_name() or scan.librarian.user.username,local.strftime('%Y-%m-%d'),local.strftime('%H:%M:%S'),'Yes' if scan.matched_catalog else 'No'])
    ws.freeze_panes='A2'; ws.auto_filter.ref=ws.dimensions
    for col in ws.columns:
        width=min(max(len(str(c.value or '')) for c in col)+2,40)
        ws.column_dimensions[col[0].column_letter].width=width
    wb.save(path); return path
