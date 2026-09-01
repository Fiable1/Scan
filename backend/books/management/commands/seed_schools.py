from django.core.management.base import BaseCommand
from books.models import School,BookCatalog
class Command(BaseCommand):
 def handle(self,*args,**kwargs):
  schools=[('GS KIGALI','Nyarugenge'),('GS KICUKIRO','Kicukiro'),('GS REMERA','Gasabo'),('ES MUSANZE','Musanze'),('GS HUYE','Huye')]
  for n,d in schools: School.objects.get_or_create(name=n,defaults={'district':d,'country':'Rwanda'})
  catalog=[('978140884626','New Oxford Primary Mathematics 6','Various','Primary 6','Mathematics','978140884626','Oxford University Press','English'),('9789988776655','Longman English Workbook 6','Pearson','Primary 6','English','9789988776655','Pearson','English'),('9781234567890','Integrated Science Learner Book 6','REB','Primary 6','Science','9781234567890','REB','English')]
  for row in catalog: BookCatalog.objects.get_or_create(code=row[0],defaults={'title':row[1],'author':row[2],'grade':row[3],'category':row[4],'isbn':row[5],'publisher':row[6],'language':row[7]})
  self.stdout.write(self.style.SUCCESS('Rwandan schools and sample catalog seeded.'))
