import os
from datetime import timedelta
from dotenv import load_dotenv

load_dotenv()

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY', 'allot-dev-secret-change-in-production')
    # Local XAMPP: mysql+pymysql://root:@localhost/allot
    # Produccion Render: se lee de la variable de entorno DATABASE_URL
    SQLALCHEMY_DATABASE_URI = os.environ.get(
        'DATABASE_URL',
        'mysql+pymysql://root:@localhost/allot'
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ENGINE_OPTIONS = {'pool_pre_ping': True}
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY', 'allot-jwt-dev-secret')
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=24)
    JSON_SORT_KEYS = False
    _cors_env = os.environ.get('CORS_ORIGINS', '')
    CORS_ORIGINS = _cors_env.split(',') if ',' in _cors_env else (_cors_env or '*')
    # Override in production: set env var CORS_ORIGINS as comma-separated list
    CORS_ORIGINS = os.environ.get('CORS_ORIGINS', '*').split(',') if ',' in os.environ.get('CORS_ORIGINS', '') else os.environ.get('CORS_ORIGINS', '*')
