import os
from datetime import timedelta
from dotenv import load_dotenv

load_dotenv()

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY', 'allot-dev-secret-change-in-production')
    # Local XAMPP: mysql+pymysql://root:@localhost/allot
    # Produccion: mysql+pymysql://user:pass@host/dbname
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL', 'mysql+pymysql://root:@localhost/allot')
