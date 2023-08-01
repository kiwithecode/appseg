from app.models.SAMM_BitacoraVisita import SAMM_BitacoraVisita, SAMM_BitacoraVisitaSchema
from app.models.SAMM_UbiPersona import SAMM_UbiPersona, SAMM_UbiPersonaSchema
from app.models.SAMM_Ubicacion import SAMM_Ubicacion, SAMM_UbicacionSchema
from app.models.SAMM_Usuario import SAMM_Usuario, SAMM_UsuarioSchema
from app.models.Persona import Persona, PersonaSchema
from app.models.SAMM_Ronda import SAMM_Ronda, SAMM_RondaSchema
from app.models.SAMM_Ubicacion import SAMM_Ubicacion, SAMM_UbicacionSchema
from app.models.SAMM_RondaAsignacion import SAMM_RondaAsignacion, SAMM_RondaAsignacionSchema
from app.models.SAMM_PropiedadAgente import SAMM_PropiedadAgente, SAMM_PropiedadAgenteSchema

from flask import jsonify, request
from flask_cors import cross_origin
from app.visitas import bp
from app.extensions import db
from sqlalchemy import text
import base64
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import date, datetime
from sqlalchemy import or_


@bp.route('/getAgentes', methods=['GET'])
@cross_origin()
@jwt_required()
def getAgentes():
    try:
        agentes = SAMM_Usuario.query.filter_by(IdPerfil=5).all()
        results = []
        for agente in agentes:
            persona=Persona.query.filter_by(Id=agente.IdPersona).first()
            rondasAgente = SAMM_RondaAsignacion.query.filter_by(IdAsignado=agente.IdPersona).all()
            results.append({
                'id': persona.Id,
                'nombre': persona.Nombres,
                'apellidos': persona.Apellidos,
                'identificacion': persona.Identificacion,
                'celular': persona.Cel_Personal,
                'status_actividad': persona.Estado,
                'status_rondas': len(rondasAgente)
            })
        return jsonify(results), 200
    except Exception as e:
        return jsonify({'message': str(e)}), 500
    

@bp.route('/getUbicaciones', methods=['GET'])
@cross_origin()
@jwt_required()
def getUbicaciones():
    try:
        ubicaciones = SAMM_Ubicacion.query.all()
        ubicacionesSchema = SAMM_UbicacionSchema(many=True)
        return jsonify(ubicacionesSchema.dump(ubicaciones)), 200
    except Exception as e:
        return jsonify({'message': str(e)}), 500
    

@bp.route('/getUrbanizaciones', methods=['GET'])
@cross_origin()
@jwt_required()
def getUrbanizaciones():
    #urbanizaciones are ubicacioes with tipo URBAnizacion
    try:
        urbanizaciones = SAMM_Ubicacion.query.filter_by(Tipo='URBANIZACION').all()
        #iterate over urbanizaciones and get the number of personas in each one
        results = []
        for urbanizacion in urbanizaciones:
            cantidad_Agentes =SAMM_PropiedadAgente.query.filter_by(idPropiedad=urbanizacion.Id).count()
            cantidad_Rondas=SAMM_RondaAsignacion.query.filter_by(IdUbicacion=urbanizacion.Id).count()
            Supervisor=Persona.query.filter_by(Id=urbanizacion.SupervisorId).first()
            if(Supervisor is None):
                Supervisor=Persona()
                Supervisor.Nombres='Sin Supervisor'
                Supervisor.Apellidos=''
            results.append({
                'id': urbanizacion.Id,
                'nombre': urbanizacion.Descripcion,
                'direccion': urbanizacion.Direccion,
                'coordenadas': urbanizacion.Coordenadas,
                'supervisor': Supervisor.Nombres + ' ' + Supervisor.Apellidos,
                'cantidad_propiedades': urbanizacion.Propiedades,
                'cantidad_Agentes': cantidad_Agentes,
                'cantidad_Rondas': cantidad_Rondas
            })
        return jsonify(results), 200
    except Exception as e:
        return jsonify({'message': str(e)}), 500
    
@bp.route('/addUbicacion', methods=['POST'])
@cross_origin()
@jwt_required()
def addUbicacion():
    try:
        usuario_actual = SAMM_Usuario.query.filter_by(Codigo=get_jwt_identity()).first()
        id_usuario_actual = usuario_actual.Id
        data = request.get_json()
        ubicacion = SAMM_Ubicacion.query.filter_by(Coordenadas=data['coordenadas']).first()
        if ubicacion:
            return jsonify({'message': 'Ubicacion ya existe'}), 500

        ubicacion = SAMM_Ubicacion(
            Codigo=data['nombre'],
            Coordenadas=data['coordenadas'] if 'coordenadas' in data else '',
            Tipo=data['tipo'],
            FechaCrea=datetime.now(),
            UsuarioCrea=id_usuario_actual,
            FechaModifica=datetime.now(),
            Descripcion=data['descripcion'],
            UsuarioModifica=id_usuario_actual,
            Direccion=data['direccion'],
            Propiedades=data['propiedades'],
            SupervisorId=data['supervisorId'],	
            Estado='A',
        )
        db.session.add(ubicacion)
        db.session.commit()
        #add to PropiedadAgente
        agentesId = data['agentes'] if 'agentes' in data else []
        for agente in agentesId:
            #make agentes id a integer if it is a string
            if isinstance(agente, str):
                agente = int(agente)
            propiedadAgente = SAMM_PropiedadAgente(
                create_time=datetime.now(),
                update_time=datetime.now(),
                content='A',
                idPropiedad=ubicacion.Id,
                idAgente=agente
            )
            db.session.add(propiedadAgente)
            db.session.commit()

        #puntos de ronda
        puntos = data['puntos'] if 'puntos' in data else []
        for punto in puntos:
            ubicacionPunto = SAMM_Ubicacion(
                Codigo=data['nombre'],
                Coordenadas=punto,
                Tipo='PUNTO',
                FechaCrea=datetime.now(),
                UsuarioCrea=id_usuario_actual,
                FechaModifica=datetime.now(),
                Descripcion=data['descripcion'],
                UsuarioModifica=id_usuario_actual,
                Direccion=data['direccion'],
                Propiedades=data['propiedades'],
                SupervisorId=data['supervisorId'],	
                Estado='A',
            )
            db.session.add(ubicacionPunto)
            db.session.commit()

        return jsonify({'message': 'Ubicacion creada'}), 200
    except Exception as e:
        return jsonify({'message': str(e)}), 500