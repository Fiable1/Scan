from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from django.db.models import Count
from django.http import FileResponse
from django.utils import timezone
from rest_framework.decorators import api_view,permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from .models import School,Librarian,BookCatalog,BookScan
from .serializers import RegisterSerializer,ScanSerializer
from .excel import build_excel

@api_view(['GET'])
@permission_classes([AllowAny])
def api_info(request): return Response({'name':'Rwanda School Book Scanner API','status':'online'})

@api_view(['GET'])
@permission_classes([AllowAny])
def schools(request): return Response([{'id':s.id,'name':s.name,'district':s.district} for s in School.objects.filter(active=True,country__iexact='Rwanda').order_by('name')])

@api_view(['GET'])
@permission_classes([AllowAny])
def districts(request):
    dists=['Gasabo','Kicukiro','Nyarugenge','Rwamagana','Muhanga','Huye','Nyamagabe','Gisagara','Nyagatare','Gatsibo','Kayonza','Kirehe','Ngoma','Bugesera','Nyanza','Nyaruguru','Ruhango','Kamonyi','Musanze','Burera','Gakenke','Gicumbi','Rulindo','Karongi','Ngororero','Nyabihu','Rubavu','Rusizi','Nyamasheke']
    dists=set(dists) | set(School.objects.filter(country__iexact='Rwanda').values_list('district',flat=True))
    return Response(sorted(d for d in dists if d))

@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    s=RegisterSerializer(data=request.data); s.is_valid(raise_exception=True); profile=s.save(); token,_=Token.objects.get_or_create(user=profile.user)
    return Response({'token':token.key,'librarian':profile.user.get_full_name(),'school':profile.school.name,'district':profile.school.district},status=201)

@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    email=request.data.get('email',''); password=request.data.get('password','')
    user=authenticate(username=email,password=password)
    if not user: return Response({'detail':'Invalid email or password.'},status=400)
    try: profile=user.librarian_profile
    except Librarian.DoesNotExist: return Response({'detail':'This account is not a registered librarian.'},status=403)
    token,_=Token.objects.get_or_create(user=user)
    return Response({'token':token.key,'librarian':user.get_full_name(),'school':profile.school.name})

@api_view(['POST'])
def logout(request): request.auth.delete(); return Response(status=204)

@api_view(['GET'])
def lookup(request):
    code=request.query_params.get('code','').strip()
    if not code: return Response({'detail':'code is required'},status=400)
    book=BookCatalog.objects.filter(code__iexact=code).first() or BookCatalog.objects.filter(isbn__iexact=code).first()
    if not book: return Response({'matched':False,'code':code})
    return Response({'matched':True,'code':code,'title':book.title,'author':book.author,'grade':book.grade,'category':book.category,'isbn':book.isbn,'publisher':book.publisher,'language':book.language})

@api_view(['POST'])
def create_scan(request):
    profile=request.user.librarian_profile
    data=request.data.copy(); code=data.get('code','').strip()
    catalog=BookCatalog.objects.filter(code__iexact=code).first() or BookCatalog.objects.filter(isbn__iexact=code).first()
    if catalog:
        for f in ['title','author','grade','category','isbn','publisher','language']:
            if not data.get(f): data[f]=getattr(catalog,f)
        data['matched_catalog']=True
    serializer=ScanSerializer(data=data,context={'request':request}); serializer.is_valid(raise_exception=True)
    scan=serializer.save(school=profile.school,librarian=profile,matched_catalog=bool(catalog))
    # Rebuild the canonical Excel workbook immediately after every individual scan.
    build_excel()
    return Response(ScanSerializer(scan,context={'request':request}).data,status=201)

@api_view(['GET'])
def list_scans(request):
    profile=request.user.librarian_profile
    qs=BookScan.objects.filter(school=profile.school).select_related('school','librarian__user').order_by('-scanned_at')
    q=request.query_params.get('q','').strip()
    if q: qs=qs.filter(code__icontains=q) | qs.filter(title__icontains=q) | qs.filter(author__icontains=q) | qs.filter(isbn__icontains=q)
    return Response(ScanSerializer(qs, many=True,context={'request':request}).data)

@api_view(['GET'])
def download_excel(request):
    profile=request.user.librarian_profile
    # Workbook is rebuilt to ensure it reflects current database records.
    path=build_excel()
    return FileResponse(open(path,'rb'),as_attachment=True,filename=f'{profile.school.name.replace(" ","_")}_book_scans.xlsx')

@api_view(['GET'])
def analytics(request):
    profile=request.user.librarian_profile; qs=BookScan.objects.filter(school=profile.school)
    today=timezone.localdate()
    by_grade=list(qs.values('grade').annotate(total=Count('id')).order_by('-total'))
    by_category=list(qs.values('category').annotate(total=Count('id')).order_by('-total'))
    recent=list(qs.order_by('-scanned_at')[:3])
    return Response({'total_books':qs.count(),'today':qs.filter(scanned_at__date=today).count(),'matched':qs.filter(matched_catalog=True).count(),'unmatched':qs.filter(matched_catalog=False).count(),'by_grade':by_grade,'by_category':by_category,'recent_scans':ScanSerializer(recent,many=True,context={'request':request}).data})
