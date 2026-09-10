from django.db import models


class School(models.Model):
    name = models.CharField(max_length=255, unique=True)
    district = models.CharField(max_length=255, blank=True, default='')
    country = models.CharField(max_length=100, default='Rwanda')
    active = models.BooleanField(default=True)

    class Meta:
        ordering = ['name']

    def __str__(self):
        return self.name


class UserProfile(models.Model):
    user = models.OneToOneField('auth.User', on_delete=models.CASCADE, related_name='profile')
    school = models.ForeignKey(School, on_delete=models.CASCADE, related_name='librarians')
    phone = models.CharField(max_length=30, blank=True, default='')
    verified = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.user.get_full_name()} - {self.school.name}"


class BookCatalog(models.Model):
    code = models.CharField(max_length=50, unique=True)
    title = models.CharField(max_length=255)
    author = models.CharField(max_length=255, blank=True, default='')
    grade = models.CharField(max_length=100, blank=True, default='')
    category = models.CharField(max_length=100, blank=True, default='')
    isbn = models.CharField(max_length=50, blank=True, default='')
    publisher = models.CharField(max_length=255, blank=True, default='')
    language = models.CharField(max_length=50, blank=True, default='')

    class Meta:
        ordering = ['title']

    def __str__(self):
        return self.title


class BookScan(models.Model):
    code = models.CharField(max_length=50, db_index=True)
    title = models.CharField(max_length=255, blank=True, default='')
    author = models.CharField(max_length=255, blank=True, default='')
    grade = models.CharField(max_length=100, blank=True, default='')
    category = models.CharField(max_length=100, blank=True, default='')
    isbn = models.CharField(max_length=50, blank=True, default='')
    publisher = models.CharField(max_length=255, blank=True, default='')
    language = models.CharField(max_length=50, blank=True, default='')
    cover = models.ImageField(upload_to='covers/', blank=True, null=True)
    matched_catalog = models.BooleanField(default=False)
    school = models.ForeignKey(School, on_delete=models.CASCADE, related_name='scans')
    librarian = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='scans')
    scanned_at = models.DateTimeField(auto_now_add=True, db_index=True)

    class Meta:
        ordering = ['-scanned_at']

    def __str__(self):
        return f"{self.code} - {self.title}"
