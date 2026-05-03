from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt
from models import db, Category

categories_bp = Blueprint('categories', __name__)


def _uid():    return int(get_jwt_identity())
def _is_admin(): return get_jwt().get('role') == 'admin'


@categories_bp.route('', methods=['GET'])
@jwt_required()
def get_categories():
    cats = Category.query.filter_by(user_id=_uid()).all()
    return jsonify([c.to_dict() for c in cats])


@categories_bp.route('', methods=['POST'])
@jwt_required()
def create_category():
    if not _is_admin():
        return jsonify({'error': 'Solo administradores'}), 403
    data = request.get_json(silent=True) or {}
    name = (data.get('name') or '').strip()
    if not name:
        return jsonify({'error': 'Nombre requerido'}), 400
    c = Category(
        name=name,
        color=data.get('color', '#4CAF50'),
        icon=data.get('icon', '📌'),
        is_custom=True,
        user_id=_uid(),
    )
    db.session.add(c)
    db.session.commit()
    return jsonify(c.to_dict()), 201


@categories_bp.route('/<string:cid>', methods=['DELETE'])
@jwt_required()
def delete_category(cid):
    if not _is_admin():
        return jsonify({'error': 'Solo administradores'}), 403
    c = Category.query.filter_by(id=cid, user_id=_uid(), is_custom=True).first_or_404()
    db.session.delete(c)
    db.session.commit()
    return jsonify({'message': 'Categoría eliminada'})
