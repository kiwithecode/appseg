from app.models.SAMM_BitacoraVisita import SAMM_BitacoraVisita, SAMM_BitacoraVisitaSchema
from app.models.SAMM_UbiPersona import SAMM_UbiPersona, SAMM_UbiPersonaSchema
from app.models.SAMM_Ubicacion import SAMM_Ubicacion, SAMM_UbicacionSchema
from app.models.SAMM_Usuario import SAMM_Usuario, SAMM_UsuarioSchema
from app.models.Persona import Persona, PersonaSchema
from app.models.SAMM_Rol import SAMM_Rol, SAMM_RolSchema

from flask import jsonify, request
from flask_cors import cross_origin
from app.visitas import bp
from app.extensions import db
from sqlalchemy import text
import base64
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import date, datetime
from sqlalchemy import or_

@bp.route('/roles', methods=['GET'])
@cross_origin()
@jwt_required()
def getRoles():
    try:
        roles = SAMM_Rol.query.all()
        rolesSchema = SAMM_RolSchema(many=True)
        return jsonify(roles=rolesSchema.dump(roles)), 200
    except Exception as e:
        return jsonify({'message': str(e)}), 500
    
@bp.route('/roles/<id>', methods=['GET'])
@cross_origin()
@jwt_required()
def getRol(id):
    try:
        rol = SAMM_Rol.query.filter_by(Id=id).first()
        if rol is None:
            return jsonify({'message': 'Rol no existe'}), 400
        rolSchema = SAMM_RolSchema()
        return jsonify(rol=rolSchema.dump(rol)), 200
    except Exception as e:
        return jsonify({'message': str(e)}), 500
    

@bp.route('/roles', methods=['POST'])
@cross_origin()
@jwt_required()
def addRol():
    try:
        user= SAMM_Usuario.query.filter_by(Codigo=get_jwt_identity()).first()
        if user is None:
            return jsonify({'message': 'Usuario no existe'}), 400
        data = request.get_json()
        rol = SAMM_Rol.query.filter_by(Nombre=data['nombre']).first()
        if rol:
            return jsonify({'message': 'Rol ya existe'}), 500

        rol = SAMM_Rol(
            Codigo=data['Codigo'],
            Descripcion=data['descripcion'],
            Estado='A',
            FechaCrea=datetime.now(),
            UsuarioCrea=user.Id,
            FechaModifica=datetime.now(),
            UsuarioModifica=user.Id,
            FechaUltimoLogin=datetime.now(),
        )
        db.session.add(rol)
        db.session.commit()

        return jsonify({'message': 'Rol creado exitosamente'}), 200


    except Exception as e:
        return jsonify({'message': str(e)}), 500
    
@bp.route('/roles/<id>', methods=['PUT'])
@cross_origin()
@jwt_required()
def updateRol(id):
    try:
        data = request.get_json()
        rol = SAMM_Rol.query.filter_by(Id=id).first()
        if rol is None:
            return jsonify({'message': 'Rol no existe'}), 400
        rol.Nombre=data['nombre']
        rol.Descripcion=data['descripcion']
        rol.Estado=data['estado']
        db.session.add(rol)
        db.session.commit()
        return jsonify({'message': 'Rol actualizado exitosamente'}), 200
    except Exception as e:
        return jsonify({'message': str(e)}), 500
    
@bp.route('/roles/<id>', methods=['DELETE'])
@cross_origin()
@jwt_required()
def deleteRol(id):
    try:
        rol = SAMM_Rol.query.filter_by(Id=id).first()
        if rol is None:
            return jsonify({'message': 'Rol no existe'}), 400
        db.session.delete(rol)
        db.session.commit()
        return jsonify({'message': 'Rol eliminado exitosamente'}), 200
    except Exception as e:
        return jsonify({'message': str(e)}), 500
