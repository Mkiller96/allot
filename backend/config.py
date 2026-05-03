import os
from datetime import timedelta
from dotenv import load_dotenv

load_dotenv()

def _fix_db_url(url):
    # Render gives postgres:// but SQLAlchemy requires postgresql://
    if url and url.startswith('postgres://'):
        return 'postgresql://' + url[len('postgres://'):]
    return url

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY', 'allot-dev-secret-change-in-production')
    # Local: sqlite:///allot.db  |  Production: set DATABASE_URL env var (Render PostgreSQL)
    SQLALCHEMY_DATABASE_URI = _fix_db_url(
        os.environ.get('DATABASE_URL', 'sqlite:///allot.db')
    )
