import os
from datetime import timedelta
from dotenv import load_dotenv

load_dotenv()

def _fix_db_url(url):
    if not url:
        return url
    # Render gives postgres:// but SQLAlchemy requires postgresql://
    if url.startswith('postgres://'):
        return 'postgresql://' + url[len('postgres://'):]
    return url

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY', 'allot-dev-secret-change-in-production')
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY', SECRET_KEY)
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(days=30)
    # Local: sqlite:///allot.db  |  Production: set DATABASE_URL env var (Render PostgreSQL)
    SQLALCHEMY_DATABASE_URI = _fix_db_url(
        os.environ.get('DATABASE_URL', 'sqlite:///allot.db')
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    CORS_ORIGINS = os.environ.get('CORS_ORIGINS', '*')
