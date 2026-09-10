from django.contrib import admin
from .models import School, UserProfile, BookCatalog, BookScan

admin.site.register(School)
admin.site.register(UserProfile)
admin.site.register(BookCatalog)
admin.site.register(BookScan)
