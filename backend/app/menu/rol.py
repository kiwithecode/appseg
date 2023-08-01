from app.models.SAMM_Opcion import SAMM_Opcion, SAMM_OpcionSchema
from app.models.SAMM_Rol import SAMM_Rol, SAMM_RolSchema
from app.models.SAMM_OpRol import SAMM_OpRol, SAMM_OpRolSchema
from app.models.SAMM_RolUsu import SAMM_RolUsu, SAMM_RolUsuSchema
from app.models.SAMM_Usuario import SAMM_Usuario, SAMM_UsuarioSchema


from flask import jsonify, request
from flask_cors import cross_origin
from app.menu import bp
from app.extensions import db
from sqlalchemy import text
import base64
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import date, datetime
from sqlalchemy import or_

@bp.route('/getRolByID/<id>', methods=['GET'])
@cross_origin()
@jwt_required()
def getRolByID(id):
    try:
        rol = SAMM_Rol.query.filter_by(Id=id).first()
        rol_schema = SAMM_RolSchema()
        return jsonify({'Rol': rol_schema.dump(rol)}), 200
    except Exception as e:
        return jsonify({'message': str(e)}), 500