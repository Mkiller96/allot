from datetime import date
from flask import Blueprint, request, jsonify, abort
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import Expense

metrics_bp = Blueprint('metrics', __name__)


def _uid():
    try:
        return int(get_jwt_identity())
    except (TypeError, ValueError):
        abort(401, description='Token inválido')


@metrics_bp.route('/monthly', methods=['GET'])
@jwt_required()
def monthly():
    year = int(request.args.get('year', date.today().year))
    exps = Expense.query.filter(
        Expense.user_id == _uid(),
        Expense.date.like(f'{year}-%'),
    ).all()
    sums = {}
    for e in exps:
        m = int(e.date[5:7])
        sums[m] = sums.get(m, 0) + e.amount
    return jsonify({
        'year':   year,
        'months': [{'month': m, 'total': round(sums.get(m, 0), 2)} for m in range(1, 13)],
    })


@metrics_bp.route('/annual', methods=['GET'])
@jwt_required()
def annual():
    year = int(request.args.get('year', date.today().year))
    exps = Expense.query.filter(
        Expense.user_id == _uid(),
        Expense.date.like(f'{year}-%'),
    ).all()

    total, by_cat, by_month = 0.0, {}, {}
    for e in exps:
        total += e.amount
        by_cat[e.category_id]       = by_cat.get(e.category_id, 0) + e.amount
        by_month[int(e.date[5:7])]  = by_month.get(int(e.date[5:7]), 0) + e.amount

    top_m   = max(by_month.items(), key=lambda x: x[1]) if by_month else None
    top_c   = max(by_cat.items(),   key=lambda x: x[1]) if by_cat   else None
    active  = len(by_month) or 1

    return jsonify({
        'year':        year,
        'total':       round(total, 2),
        'count':       len(exps),
        'avgMonth':    round(total / active, 2),
        'topMonth':    {'month': top_m[0], 'total': round(top_m[1], 2)} if top_m else None,
        'topCategory': {'id': top_c[0],    'total': round(top_c[1], 2)} if top_c else None,
        'byCategory':  [{'id': k, 'total': round(v, 2)}
                        for k, v in sorted(by_cat.items(), key=lambda x: -x[1])],
    })
