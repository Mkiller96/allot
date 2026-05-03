import uuid
from datetime import datetime
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash

db = SQLAlchemy()

DEFAULT_CATEGORIES = [
    {'id': 'food',      'name': 'Comida',     'color': '#4CAF50', 'icon': '🍔'},
    {'id': 'transport', 'name': 'Transporte', 'color': '#2196F3', 'icon': '🚌'},
    {'id': 'leisure',   'name': 'Ocio',       'color': '#FF9800', 'icon': '🎮'},
    {'id': 'bills',     'name': 'Facturas',   'color': '#9C27B0', 'icon': '🧾'},
    {'id': 'shopping',  'name': 'Compras',    'color': '#E91E63', 'icon': '🛍️'},
    {'id': 'health',    'name': 'Salud',      'color': '#00BCD4', 'icon': '💊'},
    {'id': 'other',     'name': 'Otros',      'color': '#607D8B', 'icon': '📦'},
]


class User(db.Model):
    __tablename__ = 'users'

    id            = db.Column(db.Integer, primary_key=True)
    username      = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(256), nullable=False)
    role          = db.Column(db.String(20), default='user')  # admin | user | guest
    created_at    = db.Column(db.DateTime, default=datetime.utcnow)

    expenses   = db.relationship('Expense',  backref='owner', lazy=True, cascade='all, delete-orphan')
    categories = db.relationship('Category', backref='owner', lazy=True, cascade='all, delete-orphan')

    def set_password(self, password: str) -> None:
        self.password_hash = generate_password_hash(password)

    def check_password(self, password: str) -> bool:
        return check_password_hash(self.password_hash, password)

    def to_dict(self):
        return {'id': self.id, 'username': self.username, 'role': self.role}


class Category(db.Model):
    __tablename__ = 'categories'

    id        = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name      = db.Column(db.String(80),  nullable=False)
    color     = db.Column(db.String(7),   default='#4CAF50')
    icon      = db.Column(db.String(10),  default='📌')
    is_custom = db.Column(db.Boolean,     default=False)
    user_id   = db.Column(db.Integer,     db.ForeignKey('users.id'), nullable=False)

    def to_dict(self):
        return {
            'id': self.id, 'name': self.name,
            'color': self.color, 'icon': self.icon, 'isCustom': self.is_custom,
        }


class Expense(db.Model):
    __tablename__ = 'expenses'

    id          = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    amount      = db.Column(db.Float,      nullable=False)
    category_id = db.Column(db.String(36), db.ForeignKey('categories.id'), nullable=False)
    date        = db.Column(db.String(10), nullable=False)   # YYYY-MM-DD
    note        = db.Column(db.String(255), default='')
    user_id     = db.Column(db.Integer,    db.ForeignKey('users.id'), nullable=False)
    created_at  = db.Column(db.DateTime,   default=datetime.utcnow)

    category = db.relationship('Category')

    def to_dict(self):
        return {
            'id':         self.id,
            'amount':     self.amount,
            'categoryId': self.category_id,
            'date':       self.date,
            'note':       self.note,
            'createdAt':  self.created_at.isoformat(),
        }
