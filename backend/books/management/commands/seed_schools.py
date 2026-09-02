from django.core.management.base import BaseCommand
from books.models import School, BookCatalog

class Command(BaseCommand):
 help='Seed the Rwandan school scanner book catalog.'
 def handle(self,*args,**kwargs):
  catalog=[
   ('9780199386429','New Oxford Primary Mathematics 6','Various','Primary 6','Mathematics','9780199386429','Oxford University Press','English'),
   ('9780582312104','Longman English Workbook 6','Pearson','Primary 6','English','9780582312104','Pearson','English'),
   ('9780435892258','Integrated Science Learner Book 6','REB','Primary 6','Science','9780435892258','REB','English'),
   ('9780999577302','Indimu yose 6','REB','Primary 6','Kinyarwanda','9780999577302','REB','Kinyarwanda'),
   ('9780198390022','Social Studies Learner Book 6','Longman','Primary 6','Social Studies','9780198390022','Longman','English'),
   ('9780582312098','New Longman Science for Primary 5','Longman','Primary 5','Science','9780582312098','Longman','English'),
   ('9780199386415','Oxford English for Primary 4','Oxford University Press','Primary 4','English','9780199386415','Oxford University Press','English'),
   ('9781408846266','Grade 6 Mathematics Pupils Book','REB','Primary 6','Mathematics','9781408846266','REB','English'),
  ]
  for row in catalog:
   BookCatalog.objects.get_or_create(code=row[0],defaults={'title':row[1],'author':row[2],'grade':row[3],'category':row[4],'isbn':row[5],'publisher':row[6],'language':row[7]})
  self.stdout.write(self.style.SUCCESS(f'{len(catalog)} catalog entries seeded.'))
