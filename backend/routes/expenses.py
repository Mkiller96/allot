from datetime import date
from flask import Blueprint, request, jsonify, abort
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt
from models import db, Expense

expenses_bp = Blueprint('expenses', __name__)


def _uid():
    try:
        return int(get_jwt_identity())
    except (TypeError, ValueError):
        abort(401, description='Token inválido')
def _role(): return get_jwt().get('role', 'guest')


@expenses_bp.route('', methods=['GET'])
@jwt_required()
def get_expenses():
    uid    = _uid()
    period = request.args.get('period', 'all')
    cat_id = request.args.get('categoryId', '')
    sort   = request.args.get('sort', 'newest')
    search = request.args.get('search', '').strip().lower()

    q = Expense.query.filter_by(user_id=uid)
    today = date.today()
    if period == 'month':
        q = q.filter(Expense.date.like(f'{today.year}-{today.month:02d}-%'))
    elif period == 'year':
        q = q.filter(Expense.date.like(f'{today.year}-%'))

    if cat_id:
        q = q.filter_by(category_id=cat_id)
    if search:
        q = q.filter(db.or_(
            Expense.note.ilike(f'%{search}%'),
            Expense.amount.cast(db.String).contains(search),
        ))

    order_map = {
        'newest':  (Expense.date.desc(), Expense.created_at.desc()),
        'oldest':  (Expense.date.asc(),  Expense.created_at.asc()),
        'highest': (Expense.amount.desc(),),
        'lowest':  (Expense.amount.asc(),),
    }
    q = q.order_by(*order_map.get(sort, order_map['newest']))
    return jsonify([e.to_dict() for e in q.all()])


@expenses_bp.route('', methods=['POST'])
@jwt_required()
def create_expense():
    if _role() not in ('admin', 'user'):
        return jsonify({'error': 'Sin permisos'}), 403
    data   = request.get_json(silent=True) or {}
    amount = float(data.get('amount', 0))
    if amount <= 0:
        return jsonify({'error': 'El importe debe ser mayor que 0'}), 400
    e = Expense(
        amount=amount,
        category_id=data.get('categoryId', ''),
        date=data.get('date', date.today().isoformat()),
        note=data.get('note', ''),
        user_id=_uid(),
    )
    db.session.add(e)
    db.session.commit()
    return jsonify(e.to_dict()), 201


@expenses_bp.route('/<string:eid>', methods=['PUT'])
@jwt_required()
def update_expense(eid):
    if _role() not in ('admin', 'user'):
        return jsonify({'error': 'Sin permisos'}), 403
    e    = Expense.query.filter_by(id=eid, user_id=_uid()).first_or_404()
    data = request.get_json(silent=True) or {}
    if 'amount'     in data: e.amount      = float(data['amount'])
    if 'categoryId' in data: e.category_id = data['categoryId']
    if 'date'       in data: e.date        = data['date']
    if 'note'       in data: e.note        = data['note']
    db.session.commit()
    return jsonify(e.to_dict())


@expenses_bp.route('/<string:eid>', methods=['DELETE'])
@jwt_required()
def delete_expense(eid):
    if _role() != 'admin':
        return jsonify({'error': 'Solo administradores pueden eliminar'}), 403
    e = Expense.query.filter_by(id=eid, user_id=_uid()).first_or_404()
    db.session.delete(e)
    db.session.commit()
    return jsonify({'message': 'Gasto eliminado'})
