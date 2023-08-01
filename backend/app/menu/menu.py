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
from sqlalchemy import or_, and_


@bp.route('/getMenu', methods=['GET'])
@cross_origin()
@jwt_required()
def getMenu():
    try:
        #get user id
        current_user = get_jwt_identity()
        #get user
        usuario = SAMM_Usuario.query.filter_by(Codigo=current_user).first()
        #get rol
        rol = usuario.IdPerfil
        #get opciones
        opciones = SAMM_OpRol.query.filter_by(idRol=rol).all()
        #use squema to serialize
        opcion_schema = []
        for opcion in opciones:
            gOpcion = SAMM_Opcion.query.filter(and_(SAMM_Opcion.Id == opcion.IdOpcion, SAMM_Opcion.Estado == 'A')).first()
            if gOpcion:
                # put path as '''if id is 1
                # put path as gOpcion.Descripcion.replace(" ", "-").lower().replace("á", "a").replace("é", "e").replace("í", "i").replace("ó", "o").replace("ú", "u") else
                tryPath=gOpcion.Descripcion.replace(" ", "-").lower().replace("á", "a").replace("é", "e").replace("í", "i").replace("ó", "o").replace("ú", "u")
                path='' if gOpcion.Id ==1 else tryPath
                opcion_schema.append({
                    'Id': gOpcion.Id,
                    'Codigo': gOpcion.Codigo,
                    'Estado': gOpcion.Estado,
                    'FechaCrea': gOpcion.FechaCrea,
                    'UsuarioCrea': gOpcion.UsuarioCrea,
                    'FechaModifica': gOpcion.FechaModifica,
                    'UsuarioModifica': gOpcion.UsuarioModifica,
                    'FechaUltimoLogin': gOpcion.FechaUltimoLogin,
                    'Descripcion': gOpcion.Descripcion,
                    'Icon': gOpcion.Icon,
                    'path': path
                })
        return jsonify(opcion_schema), 200
    except Exception as e:
        return jsonify({'message': str(e)}), 500