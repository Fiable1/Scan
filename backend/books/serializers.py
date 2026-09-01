from rest_framework import serializers
from django.contrib.auth.models import User
from .models import School,Librarian,BookScan

class RegisterSerializer(serializers.Serializer):
    full_name=serializers.CharField(max_length=150)
    email=serializers.EmailField()
    phone=serializers.CharField(max_length=30, required=False, allow_blank=True)
    password=serializers.CharField(write_only=True,min_length=6)
    school_id=serializers.IntegerField()
    def validate_school_id(self,v):
        try: school=School.objects.get(pk=v,active=True,country__iexact='Rwanda')
        except School.DoesNotExist: raise serializers.ValidationError('Select an active registered Rwandan school.')
        return v
    def create(self,data):
        school=School.objects.get(pk=data['school_id'])
        if User.objects.filter(username=data['email']).exists(): raise serializers.ValidationError({'email':'Already registered.'})
        user=User.objects.create_user(username=data['email'],email=data['email'],password=data['password'],first_name=data['full_name'])
        profile=Librarian.objects.create(user=user,school=school,phone=data.get('phone',''))
        return profile

class ScanSerializer(serializers.ModelSerializer):
    school=serializers.CharField(source='school.name',read_only=True)
    librarian=serializers.CharField(source='librarian.user.get_full_name',read_only=True)
    cover_url=serializers.SerializerMethodField()
    class Meta:
        model=BookScan
        fields=['id','code','title','author','grade','category','isbn','publisher','language','cover','cover_url','matched_catalog','school','librarian','scanned_at']
        read_only_fields=['matched_catalog','school','librarian','scanned_at']
    def get_cover_url(self,obj):
        req=self.context.get('request')
        return req.build_absolute_uri(obj.cover.url) if req and obj.cover else None
