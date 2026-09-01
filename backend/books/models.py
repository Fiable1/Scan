from django.db import models
from django.contrib.auth.models import User

class School(models.Model):
    name=models.CharField(max_length=255, unique=True)
    district=models.CharField(max_length=100, blank=True)
    country=models.CharField(max_length=50, default='Rwanda')
    active=models.BooleanField(default=True)
    def __str__(self): return self.name

class Librarian(models.Model):
    user=models.OneToOneField(User,on_delete=models.CASCADE,related_name='librarian_profile')
    school=models.ForeignKey(School,on_delete=models.PROTECT,related_name='librarians')
    phone=models.CharField(max_length=30, blank=True)
    verified=models.BooleanField(default=True)
    def __str__(self): return f'{self.user.get_full_name()} - {self.school.name}'

class BookCatalog(models.Model):
    code=models.CharField(max_length=100, unique=True)
    title=models.CharField(max_length=255)
    author=models.CharField(max_length=255, blank=True)
    grade=models.CharField(max_length=100, blank=True)
    category=models.CharField(max_length=100, blank=True)
    isbn=models.CharField(max_length=50, blank=True)
    publisher=models.CharField(max_length=255, blank=True)
    language=models.CharField(max_length=80, blank=True)
    def __str__(self): return self.title

class BookScan(models.Model):
    # One row = one physically scanned book. No quantity aggregation.
    code=models.CharField(max_length=100, db_index=True)
    title=models.CharField(max_length=255, blank=True)
    author=models.CharField(max_length=255, blank=True)
    grade=models.CharField(max_length=100, blank=True)
    category=models.CharField(max_length=100, blank=True)
    isbn=models.CharField(max_length=50, blank=True)
    publisher=models.CharField(max_length=255, blank=True)
    language=models.CharField(max_length=80, blank=True)
    cover=models.ImageField(upload_to='covers/%Y/%m/%d/', null=True, blank=True)
    matched_catalog=models.BooleanField(default=False)
    school=models.ForeignKey(School,on_delete=models.PROTECT,related_name='scans')
    librarian=models.ForeignKey(Librarian,on_delete=models.PROTECT,related_name='scans')
    scanned_at=models.DateTimeField(auto_now_add=True, db_index=True)
    def __str__(self): return f'{self.title or self.code} @ {self.scanned_at}'
