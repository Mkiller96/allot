from flask import Flask
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from config import Config
from models import db, User, Category, DEFAULT_CATEGORIES


def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    db.init_app(app)
    JWTManager(app)
    CORS(app, origins=app.config.get('CORS_ORIGINS', ['*']))

    from routes.auth       import auth_bp
    from routes.expenses   import expenses_bp
    from routes.categories import categories_bp
    from routes.metrics    import metrics_bp

    app.register_blueprint(auth_bp,       url_prefix='/api/auth')
    app.register_blueprint(expenses_bp,   url_prefix='/api/expenses')
    app.register_blueprint(categories_bp, url_prefix='/api/categories')
    app.register_blueprint(metrics_bp,    url_prefix='/api/metrics')

    @app.route('/')
    def index():
        return {'status': 'ok', 'message': 'Allot API running'}, 200

    @app.route('/api/health')
    def health():
        return {'status': 'ok'}, 200

    with app.app_context():
        db.create_all()
        _seed_default_admin()

    return app


def _seed_default_admin():
    """Create a default admin account if none exists."""
    if User.query.filter_by(username='admin').first():
        return
    admin = User(username='admin', role='admin')
    admin.set_password('admin123')
    db.session.add(admin)
    db.session.flush()
    for cat in DEFAULT_CATEGORIES:
        db.session.add(Category(
            id=f"{cat['id']}_{admin.id}",
            name=cat['name'], color=cat['color'],
            icon=cat['icon'], is_custom=False, user_id=admin.id,
        ))
    # Default guest account (no password needed)
    guest = User(username='invitado', role='guest')
    guest.set_password('guest')
    db.session.add(guest)
    db.session.flush()
    for cat in DEFAULT_CATEGORIES:
        db.session.add(Category(
            id=f"{cat['id']}_{guest.id}",
            name=cat['name'], color=cat['color'],
            icon=cat['icon'], is_custom=False, user_id=guest.id,
        ))
    db.session.commit()


if __name__ == '__main__':
    app = create_app()
    app.run(debug=True, host='0.0.0.0', port=5000)
