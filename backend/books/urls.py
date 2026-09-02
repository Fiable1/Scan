from django.urls import path
from . import views
urlpatterns=[
 path('',views.api_info),path('auth/register/',views.register),path('auth/login/',views.login),path('auth/logout/',views.logout),
 path('schools/',views.schools),path('districts/',views.districts),path('books/lookup/',views.lookup),path('scans/',views.create_scan),path('scans/list/',views.list_scans),path('scans/excel/',views.download_excel),path('analytics/',views.analytics),
]
