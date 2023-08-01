from xml.dom import ValidationErr
from app.models.SAMM_BitacoraVisita import SAMM_BitacoraVisita, SAMM_BitacoraVisitaSchema
from app.models.SAMM_UbiPersona import SAMM_UbiPersona, SAMM_UbiPersonaSchema
from app.models.SAMM_Ubicacion import SAMM_Ubicacion, SAMM_UbicacionSchema
from app.models.SAMM_Usuario import SAMM_Usuario, SAMM_UsuarioSchema
from app.models.Persona import Persona, PersonaSchema
from app.models.SAMM_Rol import SAMM_Rol
from app.models.SAMM_Ronda import SAMM_Ronda, SAMM_RondaSchema
from app.models.SAMM_PuntoRonda import SAMM_PuntoRonda, SAMM_PuntoRondaSchema
from werkzeug.utils import secure_filename

from flask import jsonify, request
from flask_cors import cross_origin
from app.rondas import bp
from app.extensions import db
from sqlalchemy import text
import base64
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import date, datetime
from sqlalchemy import or_


@bp.route('/rondas', methods=['GET'])
@cross_origin()
@jwt_required()
def getRondas():
    try:
        rondas = SAMM_BitacoraVisita.query.all()
        #use squema
        rondas_schema = SAMM_BitacoraVisitaSchema(many=True)
        return jsonify(rondas=rondas_schema.dump(rondas)), 200
    except Exception as e:
        return jsonify({'message': str(e)}), 500
    
@bp.route('/crearRonda', methods=['POST'])
@cross_origin()
@jwt_required()
def crearRonda():
    user_name = get_jwt_identity()
    user = SAMM_Usuario.query.filter_by(Codigo=user_name).first()
    coordenadas = request.json['coordenadas']
    observaciones = request.json['observaciones']
    estado = request.json['estado']
    direccion = request.json['direccion'] if 'direccion' in request.json else None
    try:
        ronda = SAMM_Ronda()
        ronda.Desripcion=observaciones
        ronda.FechaCreacion=datetime.now()
        ronda.Estado=estado
        ronda.UsuCreacion=user.Id
        ronda.UsuModifica=user.Id
        ronda.FechaModifica=datetime.now()
        ubicacion = SAMM_Ubicacion.query.filter_by(Coordenadas=coordenadas).first()
        if ubicacion is None:
            ubicacion = SAMM_Ubicacion()
            ubicacion.FechaModifica=datetime.now()
            ubicacion.UsuarioModifica=user.Id
            ubicacion.Tipo='RONDA'
            ubicacion.FechaCrea=datetime.now()
            ubicacion.Direccion=direccion
            ubicacion.Coordenadas=coordenadas
            ubicacion.Descripcion=direccion
            ubicacion.UsuarioCrea=user.Id
            db.session.add(ubicacion)
            db.session.commit()
        ronda.IdUbicacion=ubicacion.Id
        db.session.add(ronda)
        db.session.commit()
        puntoRonda = SAMM_PuntoRonda()
        puntoRonda.IdRonda=ronda.Id
        puntoRonda.Orden=1
        puntoRonda.Coordenada=coordenadas
        puntoRonda.Estado=estado
        print (estado)
        puntoRonda.FechaCreacion=datetime.now()
        puntoRonda.FechaModificacion=datetime.now()
        puntoRonda.UsuCreacion=user.Id
        puntoRonda.UsuModifica=user.Id
        db.session.add(puntoRonda)
       
        ronda.PuntoInicial=puntoRonda.Id
        db.session.add(ronda)
    
        return jsonify({'message': 'Ronda creada exitosamente'}), 200
    except Exception as e:
        import traceback
        print(traceback.format_exc())
        return jsonify({'message': str(e)}), 500

@bp.route('/rondas/<int:id>', methods=['GET'])
@cross_origin()
@jwt_required()
def getRonda(id):
    try:
        ronda = SAMM_BitacoraVisita.query.filter_by(Id=id).first()
        #use squema
        ronda_schema = SAMM_BitacoraVisitaSchema()
        return jsonify(ronda=ronda_schema.dump(ronda)), 200
    except Exception as e:
        return jsonify({'message': str(e)}), 500
    

def revisarRonda(id):
    #find ronda in rondapunto
    ronda = SAMM_PuntoRonda.query.filter_by(IdRonda=id).all()
    #count the number of puntos
    count = len(ronda)
    return count

@bp.route('/puntoRonda', methods=['POST'])
@cross_origin()
@jwt_required()
def puntoRonda():
    user_name = get_jwt_identity()
    user = SAMM_Usuario.query.filter_by(Codigo=user_name).first()
    coordenadas = request.json['coordenadas']
    idRonda = request.json['idRonda']
    ronda=SAMM_Ronda.query.filter_by(Id=idRonda).first()
    if ronda is None:
        return jsonify({'message': 'Ronda no existe'}), 500
    count=revisarRonda(idRonda)
    if(count==10):
        return jsonify({'message': 'Ronda completa'}), 500
    puntoRonda = SAMM_PuntoRonda()
    puntoRonda.IdRonda=idRonda
    puntoRonda.Orden=count+1
    puntoRonda.Coordenada=coordenadas
    puntoRonda.Estado='A'
    puntoRonda.FechaCreacion=datetime.now()
    puntoRonda.FechaModificacion=datetime.now()
    puntoRonda.UsuCreacion=user.Id
    puntoRonda.UsuModifica=user.Id
    db.session.add(puntoRonda)
    db.session.commit()
    if(count==9):
        ronda.Estado='C'
        ronda.PuntoFinal=puntoRonda.Id
        db.session.add(ronda)
        db.session.commit()
    return jsonify({'message': 'Punto agregado exitosamente'}), 200