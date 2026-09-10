import datetime
import io

from django.contrib.auth.models import User
from django.contrib.auth.hashers import make_password
from django.db.models import Q, Count, Case, When, Value, CharField
from django.http import HttpResponse
from django.utils import timezone
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.authentication import TokenAuthentication

from openpyxl import Workbook
from openpyxl.styles import Font

from .models import School, UserProfile, BookCatalog, BookScan


RWANDAN_DISTRICTS = [
    'Gasabo', 'Kicukiro', 'Nyarugenge', 'Rwamagana', 'Muhanga',
    'Huye', 'Nyamagabe', 'Gisagara', 'Nyagatare', 'Gatsibo',
    'Kayonza', 'Kirehe', 'Ngoma', 'Bugesera', 'Nyanza',
    'Nyaruguru', 'Ruhango', 'Kamonyi', 'Musanze', 'Burera',
    'Gakenke', 'Gicumbi', 'Rulindo', 'Karongi', 'Ngororero',
    'Nyabihu', 'Rubavu', 'Rusizi', 'Nyamasheke',
]

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


def seed_catalog():
    if BookCatalog.objects.exists():
        return
    for item in SEED_CATALOG:
        BookCatalog.objects.get_or_create(code=item['code'], defaults=item)


def _scan_response(scan, request=None):
    cover_url = None
    if scan.cover:
        cover_url = request.build_absolute_uri(scan.cover.url) if request else scan.cover.url
    return {
        'id': scan.id,
        'code': scan.code,
        'title': scan.title,
        'author': scan.author,
        'grade': scan.grade,
        'category': scan.category,
        'isbn': scan.isbn,
        'publisher': scan.publisher,
        'language': scan.language,
        'cover_url': cover_url,
        'matched_catalog': scan.matched_catalog,
        'school': scan.school.name if scan.school else '',
        'librarian': scan.librarian.user.get_full_name() if scan.librarian else '',
        'scanned_at': scan.scanned_at.isoformat() if scan.scanned_at else None,
    }


def _get_profile(user):
    try:
        return UserProfile.objects.select_related('school').get(user=user)
    except UserProfile.DoesNotExist:
        return None


def _lookup_book(code):
    if not code:
        return None
    code = code.strip()
    try:
        return BookCatalog.objects.get(code__iexact=code)
    except BookCatalog.DoesNotExist:
        pass
    try:
        return BookCatalog.objects.get(isbn__iexact=code)
    except BookCatalog.DoesNotExist:
        return None


@api_view(['GET'])
def api_root(request):
    return Response({'name': 'Rwanda School Book Scanner API', 'status': 'online'})


@api_view(['POST'])
@permission_classes([AllowAny])
def register_view(request):
    full_name = request.data.get('full_name', '').strip()
    email = request.data.get('email', '').strip().lower()
    password = request.data.get('password', '')
    phone = request.data.get('phone', '').strip()
    district = request.data.get('district', '').strip()
    school_name = request.data.get('school_name', '').strip()

    if not full_name or not email or not password or not school_name:
        return Response(
            {'detail': 'full_name, email, password, and school_name are required.'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    if User.objects.filter(email=email).exists():
        return Response(
            {'detail': {'email': 'Already registered.'}},
            status=status.HTTP_400_BAD_REQUEST,
        )

    parts = full_name.split(None, 1)
    first_name = parts[0]
    last_name = parts[1] if len(parts) > 1 else ''

    user = User.objects.create(
        username=email,
        email=email,
        first_name=first_name,
        last_name=last_name,
        password=make_password(password),
    )

    school, _ = School.objects.get_or_create(
        name=school_name,
        defaults={'district': district, 'country': 'Rwanda', 'active': True},
    )

    UserProfile.objects.create(user=user, school=school, phone=phone)

    token, _ = Token.objects.get_or_create(user=user)

    return Response({
        'token': token.key,
        'librarian': user.get_full_name(),
        'school': school.name,
        'district': school.district,
    }, status=status.HTTP_201_CREATED)


@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    email = request.data.get('email', '').strip().lower()
    password = request.data.get('password', '')

    if not email or not password:
        return Response(
            {'detail': 'Email and password are required.'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    try:
        user = User.objects.get(email=email)
    except User.DoesNotExist:
        return Response(
            {'detail': 'Invalid email or password.'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    if not user.check_password(password):
        return Response(
            {'detail': 'Invalid email or password.'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    try:
        profile = UserProfile.objects.select_related('school').get(user=user)
    except UserProfile.DoesNotExist:
        return Response(
            {'detail': 'This account is not a registered librarian.'},
            status=status.HTTP_403_FORBIDDEN,
        )

    token, _ = Token.objects.get_or_create(user=user)

    return Response({
        'token': token.key,
        'librarian': user.get_full_name(),
        'school': profile.school.name,
    })


@api_view(['POST'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def logout_view(request):
    try:
        request.user.auth_token.delete()
    except Exception:
        pass
    return Response(status=status.HTTP_204_NO_CONTENT)


@api_view(['GET'])
@permission_classes([AllowAny])
def school_list(request):
    schools = School.objects.filter(active=True, country__iexact='rwanda').order_by('name')
    return Response([{'id': s.id, 'name': s.name, 'district': s.district} for s in schools])


@api_view(['GET'])
@permission_classes([AllowAny])
def district_list(request):
    db_districts = School.objects.filter(country__iexact='rwanda').values_list('district', flat=True).distinct()
    all_districts = sorted(set(RWANDAN_DISTRICTS) | {d for d in db_districts if d})
    return Response(all_districts)


@api_view(['GET'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def book_lookup(request):
    code = request.query_params.get('code', '').strip()
    if not code:
        return Response({'detail': 'code is required'}, status=status.HTTP_400_BAD_REQUEST)

    book = _lookup_book(code)
    if not book:
        return Response({'matched': False, 'code': code})

    return Response({
        'matched': True,
        'code': code,
        'title': book.title,
        'author': book.author,
        'grade': book.grade,
        'category': book.category,
        'isbn': book.isbn,
        'publisher': book.publisher,
        'language': book.language,
    })


@api_view(['GET'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def scan_list(request):
    profile = _get_profile(request.user)
    if not profile:
        return Response({'detail': 'Librarian profile not found.'}, status=status.HTTP_403_FORBIDDEN)

    q = request.query_params.get('q', '').strip()
    scans = BookScan.objects.filter(school=profile.school)
    if q:
        scans = scans.filter(
            Q(code__icontains=q) |
            Q(title__icontains=q) |
            Q(author__icontains=q) |
            Q(isbn__icontains=q)
        )
    scans = scans.select_related('school', 'librarian__user').order_by('-scanned_at')
    return Response([_scan_response(s, request) for s in scans])


@api_view(['POST'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def scan_create(request):
    profile = _get_profile(request.user)
    if not profile:
        return Response({'detail': 'Librarian profile not found.'}, status=status.HTTP_403_FORBIDDEN)

    code = request.data.get('code', '').strip()
    matched_catalog = False
    catalog = _lookup_book(code)

    data = {
        'code': code,
        'title': request.data.get('title', ''),
        'author': request.data.get('author', ''),
        'grade': request.data.get('grade', ''),
        'category': request.data.get('category', ''),
        'isbn': request.data.get('isbn', ''),
        'publisher': request.data.get('publisher', ''),
        'language': request.data.get('language', ''),
    }

    if catalog:
        matched_catalog = True
        for field in ['title', 'author', 'grade', 'category', 'isbn', 'publisher', 'language']:
            if not data[field] or data[field].strip() == '':
                data[field] = getattr(catalog, field, '')

    cover = request.FILES.get('cover')

    scan = BookScan.objects.create(
        code=data['code'],
        title=data['title'],
        author=data['author'],
        grade=data['grade'],
        category=data['category'],
        isbn=data['isbn'],
        publisher=data['publisher'],
        language=data['language'],
        cover=cover,
        matched_catalog=matched_catalog,
        school=profile.school,
        librarian=profile,
    )

    return Response(_scan_response(scan, request), status=status.HTTP_201_CREATED)


@api_view(['GET'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def scan_excel(request):
    profile = _get_profile(request.user)
    if not profile:
        return Response({'detail': 'Librarian profile not found.'}, status=status.HTTP_403_FORBIDDEN)

    scans = BookScan.objects.filter(school=profile.school) \
        .select_related('school', 'librarian__user') \
        .order_by('scanned_at')

    wb = Workbook()
    ws = wb.active
    ws.title = 'Book Scans'

    columns = [
        ('Title', 30),
        ('Author', 25),
        ('Grade / Level', 18),
        ('ISBN', 18),
        ('Barcode / Code', 18),
        ('Category', 18),
        ('Publisher', 25),
        ('Language', 15),
        ('Cover File', 20),
        ('School', 25),
        ('Librarian', 25),
        ('Date Scanned', 15),
        ('Time Scanned', 15),
        ('Matched Catalog', 18),
    ]

    for col_idx, (header, width) in enumerate(columns, 1):
        cell = ws.cell(row=1, column=col_idx, value=header)
        cell.font = Font(bold=True)
        ws.column_dimensions[cell.column_letter].width = width

    ws.freeze_panes = 'A2'

    for row_idx, scan in enumerate(scans, 2):
        local = timezone.localtime(scan.scanned_at) if scan.scanned_at else None
        values = [
            scan.title,
            scan.author,
            scan.grade,
            scan.isbn,
            scan.code,
            scan.category,
            scan.publisher,
            scan.language,
            str(scan.cover) if scan.cover else '',
            scan.school.name if scan.school else '',
            scan.librarian.user.get_full_name() if scan.librarian else '',
            local.strftime('%Y-%m-%d') if local else '',
            local.strftime('%H:%M:%S') if local else '',
            'Yes' if scan.matched_catalog else 'No',
        ]
        for col_idx, val in enumerate(values, 1):
            ws.cell(row=row_idx, column=col_idx, value=val)

    buf = io.BytesIO()
    wb.save(buf)
    buf.seek(0)

    school_name = (profile.school.name or 'school').replace(' ', '_')
    filename = f'{school_name}_book_scans.xlsx'

    response = HttpResponse(
        buf.getvalue(),
        content_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    )
    response['Content-Disposition'] = f'attachment; filename="{filename}"'
    return response


@api_view(['GET'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def analytics_view(request):
    profile = _get_profile(request.user)
    if not profile:
        return Response({'detail': 'Librarian profile not found.'}, status=status.HTTP_403_FORBIDDEN)

    school = profile.school
    today = timezone.now().replace(hour=0, minute=0, second=0, microsecond=0)
    tomorrow = today + datetime.timedelta(days=1)

    qs = BookScan.objects.filter(school=school)

    total_books = qs.count()
    today_count = qs.filter(scanned_at__gte=today, scanned_at__lt=tomorrow).count()
    matched_count = qs.filter(matched_catalog=True).count()
    unmatched_count = qs.filter(matched_catalog=False).count()

    by_category = list(
        qs.annotate(
            cat=Case(
                When(category='', then=Value('Others')),
                default='category',
                output_field=CharField(),
            )
        ).values('cat').annotate(total=Count('id')).order_by('-total')
    )

    by_grade = list(
        qs.annotate(
            gr=Case(
                When(grade='', then=Value('Unknown')),
                default='grade',
                output_field=CharField(),
            )
        ).values('gr').annotate(total=Count('id')).order_by('-total')
    )

    recent = qs.select_related('librarian__user').order_by('-scanned_at')[:3]

    return Response({
        'total_books': total_books,
        'today': today_count,
        'matched': matched_count,
        'unmatched': unmatched_count,
        'by_category': [{'category': c['cat'], 'total': c['total']} for c in by_category],
        'by_grade': [{'grade': g['gr'], 'total': g['total']} for g in by_grade],
        'recent_scans': [_scan_response(s, request) for s in recent],
    })
