
from flask import Flask, jsonify

from app.config import Config

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    from app.extensions import db
    db.init_app(app)

    from app.extensions import ma
    ma.init_app(app)

    from app.extensions import cors
    cors.init_app(app,resources={r"/*": {"origins": "*", "headers":["Content-Type", "Authorization"]}})

    from app.extensions import jwt
    jwt.init_app(app)

    from app.login import bp as login_bp
    app.register_blueprint(login_bp, url_prefix='/login')

    from app.visitas import bp as visitas_bp
    app.register_blueprint(visitas_bp, url_prefix='/visitas')


    from app.menu import bp as menu_bp
    app.register_blueprint(menu_bp, url_prefix='/menu')
    
    from app.rondas import bp as rondas_bp
    app.register_blueprint(rondas_bp, url_prefix='/rondas')
    
    @app.route('/')
    def index():
        endpoints = []
        for rule in app.url_map.iter_rules():
            endpoints.append(str(rule))
        return jsonify(endpoints=endpoints)
    
    return app