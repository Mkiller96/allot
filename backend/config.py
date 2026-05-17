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
    # If someone accidentally set a mysql:// URL, force it to postgresql
    if url.startswith('mysql://'):
        return 'postgresql://' + url[len('mysql://'):]
    return url

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY', 'allot-dev-secret-change-in-production')
    # Local: sqlite:///allot.db  |  Production: set DATABASE_URL env var (Render PostgreSQL)
    SQLALCHEMY_DATABASE_URI = _fix_db_url(
        os.environ.get('DATABASE_URL', 'sqlite:///allot.db')
    )
