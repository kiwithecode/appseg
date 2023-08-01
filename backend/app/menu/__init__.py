from flask import Blueprint
from flask_cors import CORS

bp = Blueprint('menu', __name__)


cors = CORS(bp,resources={r"/*": {"origins": "*", "headers":["Content-Type"]}})

from app.menu import menu
from app.menu import insert
from app.menu import rol