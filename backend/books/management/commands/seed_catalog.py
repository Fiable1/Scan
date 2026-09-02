from django.core.management import call_command
from django.core.management.base import BaseCommand

class Command(BaseCommand):
 help='Alias to seed the book catalog and reference data.'
 def handle(self,*args,**kwargs):
  call_command('seed_schools', *args, **kwargs)
