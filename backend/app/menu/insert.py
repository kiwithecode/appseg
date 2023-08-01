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


@bp.route('/addOpcion', methods=['POST'])
@cross_origin()
def addOpcion():
    try:
        # get opcion data
        data = request.get_json()
        # create opcion object
        opcion = SAMM_Opcion(
            Codigo=data['Codigo'],
            Estado='A',
            FechaCrea=datetime.now(),
            UsuarioCrea=1,
            FechaModifica=datetime.now(),
            UsuarioModifica=1,
            Descripcion=data['Descripcion'],
            FechaUltimoLogin=datetime.now()
        )
        # add opcion to the database
        db.session.add(opcion)
        db.session.commit()
        return jsonify({'message': 'Opcion agregada correctamente'}), 200
    except Exception as e:
        return jsonify({'message': str(e)}), 500
    

@bp.route('/addOpcionRol', methods=['POST'])
@cross_origin()
def addOpcionRol():
    try:
        # get opcion data
        data = request.get_json()
        # create opcion object
        opcion = SAMM_OpRol(
            IdOpcion=data['IdOpcion'],
            idRol=data['IdRol'],
            FechaCreacion=datetime.now(),
            UsuarioCreacion=1,
        )
        # add opcion to the database
        db.session.add(opcion)
        db.session.commit()
        return jsonify({'message': 'Opcion agregada correctamente'}), 200
    except Exception as e:
        return jsonify({'message': str(e)}), 500
    
#update opcion
@bp.route('/updateOpcion/<id>', methods=['PUT'])
@cross_origin()
def updateOpcion(id):
    #update the option with the fields given in the request. It can be any number of fields.
    try:
        data = request.get_json()
        opcion = SAMM_Opcion.query.filter_by(Id=id).first()
        #iterate over the data and update the fields
        for key, value in data.items():
            #update the record in the database
            setattr(opcion, key, value)
        db.session.commit()
        return jsonify({'message': 'Opcion actualizada correctamente'}), 200
    except Exception as e:
        return jsonify({'message': str(e)}), 500