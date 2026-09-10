from Mangum import Mangum
from config.wsgi import application

handler = Mangum(application)
