from django.urls import path
from . import views

urlpatterns = [
    path('', views.api_root, name='api-root'),

    path('auth/register/', views.register_view, name='register'),
    path('auth/login/', views.login_view, name='login'),
    path('auth/logout/', views.logout_view, name='logout'),

    path('schools/', views.school_list, name='school-list'),
    path('districts/', views.district_list, name='district-list'),

    path('books/lookup/', views.book_lookup, name='book-lookup'),

    path('scans/', views.scan_create, name='scan-create'),
    path('scans/list/', views.scan_list, name='scan-list'),
    path('scans/excel/', views.scan_excel, name='scan-excel'),

    path('analytics/', views.analytics_view, name='analytics'),
]
