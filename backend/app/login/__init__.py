from flask import Blueprint
from flask_cors import CORS



bp = Blueprint('login', __name__)

cors = CORS(bp,resources={r"/*": {"origins": "*", "headers":["Content-Type"]}})

from app.login import login
from app.login import register

# Path: backend\app\login\login.py