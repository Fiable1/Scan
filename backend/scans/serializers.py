from rest_framework import serializers
from .models import School, UserProfile, BookCatalog, BookScan


class SchoolSerializer(serializers.ModelSerializer):
    class Meta:
        model = School
        fields = ['id', 'name', 'district']


class BookScanSerializer(serializers.ModelSerializer):
    cover_url = serializers.SerializerMethodField()
    matched_catalog = serializers.BooleanField(source='matchedCatalog', read_only=True) if False else serializers.BooleanField()
    school_name = serializers.SerializerMethodField()
    librarian_name = serializers.SerializerMethodField()
    scanned_at = serializers.DateTimeField()

    class Meta:
        model = BookScan
        fields = [
            'id', 'code', 'title', 'author', 'grade', 'category',
            'isbn', 'publisher', 'language', 'cover_url', 'matched_catalog',
            'school_name', 'librarian_name', 'scanned_at',
        ]

    def get_cover_url(self, obj):
        if obj.cover:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.cover.url)
            return obj.cover.url
        return None

    def get_school_name(self, obj):
        return obj.school.name if obj.school else ''

    def get_librarian_name(self, obj):
        return obj.librarian.user.get_full_name() if obj.librarian else ''


class BookScanCreateSerializer(serializers.Serializer):
    code = serializers.CharField(max_length=50)
    title = serializers.CharField(max_length=255, required=False, default='')
    author = serializers.CharField(max_length=255, required=False, default='')
    grade = serializers.CharField(max_length=100, required=False, default='')
    category = serializers.CharField(max_length=100, required=False, default='')
    isbn = serializers.CharField(max_length=50, required=False, default='')
    publisher = serializers.CharField(max_length=255, required=False, default='')
    language = serializers.CharField(max_length=50, required=False, default='')
    cover = serializers.ImageField(required=False, allow_null=True)
