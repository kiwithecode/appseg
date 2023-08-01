#crud for  SAMM_Usuario

#crud for  SAMM_Usuario

from app.models.Persona import Persona, PersonaSchema
from app.models.SAMM_Usuario import SAMM_Usuario, SAMM_UsuarioSchema

from flask import jsonify, request
from flask_cors import cross_origin
from app.visitas import bp
from app.extensions import db
from sqlalchemy import text
import base64
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import date, datetime
from sqlalchemy import or_


@bp.route('/usuarios', methods=['GET'])
@cross_origin()
@jwt_required()
def getUsuarios():
    try:
        usuarios = SAMM_Usuario.query.all()
        usuariosSchema = SAMM_UsuarioSchema(many=True)
        return jsonify(usuarios=usuariosSchema.dump(usuarios)), 200
    except Exception as e:
        return jsonify({'message': str(e)}), 500
    
@bp.route('/usuarios/<id>', methods=['GET'])
@cross_origin()
@jwt_required()
def getUsuario(id):
    try:
        usuario = SAMM_Usuario.query.filter_by(Id=id).first()
        if usuario is None:
            return jsonify({'message': 'Usuario no existe'}), 400
        usuarioSchema = SAMM_UsuarioSchema()
        #addp persona data
        ubiPersona = Persona.query.filter_by(Id=usuario.IdPersona).first()
        if ubiPersona is None:
            return jsonify({'message': 'Persona no existe'}), 400
        ubiPersonaSchema = PersonaSchema()
        return jsonify(usuario=usuarioSchema.dump(usuario), persona=ubiPersonaSchema.dump(ubiPersona)), 200
    except Exception as e:
        return jsonify({'message': str(e)}), 500
    
@bp.route('/usuarios', methods=['POST'])
@cross_origin()
@jwt_required()
def addUsuario():
    try:
        user= SAMM_Usuario.query.filter_by(Codigo=get_jwt_identity()).first()
        if user is None:
            return jsonify({'message': 'Usuario no existe'}), 400
        data = request.get_json()
        usuario = SAMM_Usuario.query.filter_by(Codigo=data['codigo']).first()
        if usuario:
            return jsonify({'message': 'Usuario ya existe'}), 500

        usuario = SAMM_Usuario(
            Codigo=data['codigo'],
            IdPersona=data['idPersona'],
            Clave=data['clave'],
            Estado='A',
            FechaCrea=datetime.now(),
            UsuarioCrea=user.Id,
            FechaModifica=datetime.now(),
            UsuarioModifica=user.Id,
            IdRol=data['idRol']
        )
        db.session.add(usuario)
        db.session.commit()
        return jsonify({'message': 'Usuario agregado exitosamente'}), 200
    except Exception as e:
        return jsonify({'message': str(e)}), 500
    

@bp.route('/usuarios/<id>', methods=['PUT'])
@cross_origin()
@jwt_required()
def updateUsuario(id):
    try:
        user= SAMM_Usuario.query.filter_by(Codigo=get_jwt_identity()).first()
        if user is None:
            return jsonify({'message': 'Usuario no existe'}), 400
        usuario = SAMM_Usuario.query.filter_by(Id=id).first()
        if usuario is None:
            return jsonify({'message': 'Usuario no existe'}), 400
        data = request.get_json()
        usuario.Codigo=data['codigo'] if data['codigo'] else usuario.Codigo
        usuario.IdPersona=data['idPersona'] if data['idPersona'] else usuario.IdPersona
        usuario.Clave=data['clave'] if data['clave'] else usuario.Clave
        usuario.Estado=data['estado'] if data['estado'] else usuario.Estado
        usuario.FechaModifica=datetime.now()
        usuario.UsuarioModifica=user.Id 
        usuario.IdRol=data['idRol'] if data['idRol'] else usuario.IdRol
        db.session.commit()
        return jsonify({'message': 'Usuario actualizado exitosamente'}), 200
    except Exception as e:
        return jsonify({'message': str(e)}), 500
    
@bp.route('/usuarios/<id>', methods=['DELETE'])
@cross_origin()
@jwt_required()
def deleteUsuario(id):
    try:
        usuario = SAMM_Usuario.query.filter_by(Id=id).first()
        if usuario is None:
            return jsonify({'message': 'Usuario no existe'}), 400
        db.session.delete(usuario)
        db.session.commit()
        return jsonify({'message': 'Usuario eliminado exitosamente'}), 200
    except Exception as e:
        return jsonify({'message': str(e)}), 500
    