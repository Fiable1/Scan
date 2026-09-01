from django.contrib import admin
from .models import School,Librarian,BookCatalog,BookScan
admin.site.register([School,Librarian,BookCatalog,BookScan])
