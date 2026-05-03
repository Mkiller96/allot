from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, get_jwt, get_jwt_identity
from models import db, User, Category, DEFAULT_CATEGORIES

auth_bp = Blueprint('auth', __name__)


@auth_bp.route('/register', methods=['POST'])
def register():
    data     = request.get_json(silent=True) or {}
    username = (data.get('username') or '').strip()
    password = data.get('password', '')
    role     = data.get('role', 'user')

    if not username or not password:
        return jsonify({'error': 'Username y contraseña requeridos'}), 400
    if role not in ('admin', 'user', 'guest'):
        role = 'user'
    if User.query.filter_by(username=username).first():
        return jsonify({'error': 'El nombre de usuario ya existe'}), 409

    user = User(username=username, role=role)
    user.set_password(password)
    db.session.add(user)
    db.session.flush()

    for cat in DEFAULT_CATEGORIES:
        db.session.add(Category(
            id=f"{cat['id']}_{user.id}",
            name=cat['name'], color=cat['color'],
            icon=cat['icon'], is_custom=False, user_id=user.id,
        ))
    db.session.commit()

    token = create_access_token(identity=str(user.id),
                                additional_claims={'role': user.role})
    return jsonify({'token': token, 'user': user.to_dict()}), 201


@auth_bp.route('/login', methods=['POST'])
def login():
    data     = request.get_json(silent=True) or {}
    username = (data.get('username') or '').strip()
    password = data.get('password', '')

    if not username:
        return jsonify({'error': 'Username requerido'}), 400

    user = User.query.filter_by(username=username).first()

    if user and user.role == 'guest':
        token = create_access_token(identity=str(user.id),
                                    additional_claims={'role': user.role})
        return jsonify({'token': token, 'user': user.to_dict()})

    if not user or not user.check_password(password):
        return jsonify({'error': 'Credenciales incorrectas'}), 401

    token = create_access_token(identity=str(user.id),
                                additional_claims={'role': user.role})
    return jsonify({'token': token, 'user': user.to_dict()})
