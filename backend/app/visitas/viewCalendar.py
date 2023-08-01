from app.models.SAMM_BitacoraVisita import SAMM_BitacoraVisita, SAMM_BitacoraVisitaSchema
from app.models.SAMM_UbiPersona import SAMM_UbiPersona, SAMM_UbiPersonaSchema
from app.models.SAMM_Ubicacion import SAMM_Ubicacion, SAMM_UbicacionSchema
from app.models.SAMM_Usuario import SAMM_Usuario, SAMM_UsuarioSchema
from app.models.Persona import Persona, PersonaSchema
from werkzeug.security import generate_password_hash, check_password_hash
from flask_jwt_extended import create_access_token
from dateutil.parser import parse
from collections import defaultdict

from flask import jsonify, request
from flask_cors import cross_origin
from app.visitas import bp
from app.extensions import db
from sqlalchemy import text
import base64
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import date, datetime
import time
from sqlalchemy import or_


@bp.route('/viewCalendar', methods=['POST'])
@cross_origin()
@jwt_required()
def viewCalendar():
    '''
    tipo can be
      ENTRADAS, SALIDAS, INVITACIONES, ALERTAS, SEGUIMIENTO
            title: "5", // Número total registrado (puedes reemplazar "5" por cualquier número)
        start: fechaActual.toDate(),
        end: fechaActual.toDate(),
        tipo: tipo,
        total: 5,
    '''
    data = request.get_json()
    tipo = data['tipo']


    if tipo == 'ENTRADAS' :
    #return all
        bitacoras = SAMM_BitacoraVisita.query.all()
    elif tipo == 'SALIDAS':
        bitacoras = SAMM_BitacoraVisita.query.filter(SAMM_BitacoraVisita.FechaSalidaReal != None).all()
    elif tipo == 'ALERTAS':
        bitacoras = SAMM_BitacoraVisita.query.filter(
            (SAMM_BitacoraVisita.FechaSalidaReal == None)
            | (SAMM_BitacoraVisita.FechaSalidaReal > SAMM_BitacoraVisita.FechaSalidaEstimada)
        ).all()
    elif tipo == 'INVITACIONES':
        bitacoras = SAMM_BitacoraVisita.query.filter(
            (SAMM_BitacoraVisita.Estado != 'A')
        ).all()
    elif tipo == 'SEGUIMIENTO':
        bitacoras = SAMM_BitacoraVisita.query.filter(
            (SAMM_BitacoraVisita.FechaSalidaReal == None)
        ).all()
    else:
        return jsonify({"error": "Invalid tipo. Please provide a valid tipo."}), 400
    #check view from request
    view= data['view']
    #if view == 'day':
        #
    result = defaultdict(list)

    for bitacora in bitacoras:
        # Get the day as a string in the format 'YYYY-MM-DD'
        day = bitacora.FechaVisita.strftime("%Y-%m-%d")

        # Append the event to the list corresponding to the day key
        result[day].append({
            'title': bitacora.Descripcion,
            'inicio_visita': bitacora.FechaVisita,
            'salida_visita': bitacora.FechaSalidaReal,
            'duracion': bitacora.Duracion,
            'salida_estimada': bitacora.FechaSalidaEstimada,
            'tipo': tipo,
            'total': 1,  # Set the initial total count to 1 for each event
        })

    # Convert the defaultdict to a regular dictionary
    result = dict(result)

    # Update the total count for each day's events
    for day_events in result.values():
        total = sum(event['total'] for event in day_events)
        for event in day_events:
            event['total'] = total

    # Return the result as JSON
    return jsonify(result)

@bp.route('/viewList', methods=['POST'])
@cross_origin()
@jwt_required()
def viewList():
    '''
    tipo can be
      ENTRADAS, SALIDAS, INVITACIONES, ALERTAS, SEGUIMIENTO
            title: "5", // Número total registrado (puedes reemplazar "5" por cualquier número)
        start: fechaActual.toDate(),
        end: fechaActual.toDate(),
        tipo: tipo,
        total: 5,
    '''
    data = request.get_json()
    tipo = data['tipo']
    print(tipo)
    if tipo == 'ENTRADAS' :
    #return all
        bitacoras = SAMM_BitacoraVisita.query.all()
    elif tipo == 'RECIENTES':
        #return the 10 most recent
        bitacoras = SAMM_BitacoraVisita.query.order_by(SAMM_BitacoraVisita.FechaVisita.desc()).limit(10).all()
    elif tipo == 'ATRASADAS':
        #return the most recent 10 that are not completed
        bitacoras = SAMM_BitacoraVisita.query.filter(
            (SAMM_BitacoraVisita.FechaSalidaReal == None)
            | (SAMM_BitacoraVisita.FechaSalidaReal > SAMM_BitacoraVisita.FechaSalidaEstimada)
        ).order_by(SAMM_BitacoraVisita.FechaVisita.desc()).all()
    elif tipo == 'NEGADAS':
        bitacoras = SAMM_BitacoraVisita.query.filter(
            (SAMM_BitacoraVisita.Estado == 'N')
        ).order_by(SAMM_BitacoraVisita.FechaVisita.desc()).all()
    elif tipo == 'SIN_CODIGO':
        #where Codigo is null
        bitacoras = SAMM_BitacoraVisita.query.filter(
            (SAMM_BitacoraVisita.Codigo == None)
        ).order_by(SAMM_BitacoraVisita.FechaVisita.desc()).all()

    elif tipo == 'PROXIMAS':
        #return the most recent 10 that are not completed
        bitacoras = SAMM_BitacoraVisita.query.filter(
            (SAMM_BitacoraVisita.FechaSalidaReal == None)
            | (SAMM_BitacoraVisita.FechaSalidaReal > SAMM_BitacoraVisita.FechaSalidaEstimada)
        ).order_by(SAMM_BitacoraVisita.FechaVisita.desc()).all()
    elif tipo == 'SALIDAS':
        bitacoras = SAMM_BitacoraVisita.query.filter(SAMM_BitacoraVisita.FechaSalidaReal != None).all()
    elif tipo == 'ALERTAS':
        bitacoras = SAMM_BitacoraVisita.query.filter(
            (SAMM_BitacoraVisita.FechaSalidaReal == None)
            | (SAMM_BitacoraVisita.FechaSalidaReal > SAMM_BitacoraVisita.FechaSalidaEstimada)
        ).all()
    elif tipo == 'INVITACIONES':
        bitacoras = SAMM_BitacoraVisita.query.filter(
            (SAMM_BitacoraVisita.Estado != 'A')
        ).all()
    elif tipo == 'SEGUIMIENTO':
        bitacoras = SAMM_BitacoraVisita.query.filter(
            (SAMM_BitacoraVisita.FechaSalidaReal == None)
        ).all()
    else:
        return jsonify({"error": "Invalid tipo. Please provide a valid tipo."}), 400
    result = []
    #order by fecha de visita more recent first
    bitacoras = sorted(bitacoras, key=lambda x: x.FechaVisita, reverse=True)
    for bitacora in bitacoras:
        persona= Persona.query.filter_by(Id=bitacora.IdVisita).first()
        
        result.append({
            'id': bitacora.Id,
            'nombre': persona.Nombres,
            'apellido': persona.Apellidos,
            'identificacion': persona.Identificacion,
            #'propiedad': bitacora.IdPropiedad,
            'hora_ingreso': bitacora.FechaVisita,	
            'celular': persona.Cel_Personal,
            'hora_salida': bitacora.FechaSalidaReal,
            'hora_estimada': bitacora.FechaSalidaEstimada,
            'duracion': bitacora.Duracion,
            'placa': bitacora.Placa,
            'observaciones': bitacora.Descripcion,
            'invitacionCreada': bitacora.Estado!='A',
            'estado': bitacora.Estado,

        })
    return jsonify(result)


@bp.route('/getCountTipo', methods=['GET'])
@cross_origin()
@jwt_required()
def getCountTipo():
    #return the count of each tipo, ENTRADAS, SALIDAS, INVITACIONES, ALERTAS, SEGUIMIENTO
    bitacorasEntradas = SAMM_BitacoraVisita.query.all()
    bitacorasSalidas = SAMM_BitacoraVisita.query.filter(SAMM_BitacoraVisita.FechaSalidaReal != None).all()
    bitacorasAlertas = SAMM_BitacoraVisita.query.filter(
        (SAMM_BitacoraVisita.FechaSalidaReal == None)
        | (SAMM_BitacoraVisita.FechaSalidaReal > SAMM_BitacoraVisita.FechaSalidaEstimada)
    ).all()
    bitacorasInvitaciones = SAMM_BitacoraVisita.query.filter(
        (SAMM_BitacoraVisita.Estado != 'A')
    ).all()
    bitacorasSeguimiento = SAMM_BitacoraVisita.query.filter(
        (SAMM_BitacoraVisita.FechaSalidaReal == None)
    ).all()

    return jsonify({
        'ENTRADAS': len(bitacorasEntradas),
        'SALIDAS': len(bitacorasSalidas),
        'ALERTAS': len(bitacorasAlertas),
        'INVITACIONES': len(bitacorasInvitaciones),
        'SEGUIMIENTO': len(bitacorasSeguimiento),
    })