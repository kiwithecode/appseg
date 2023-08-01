from app.models.SAMM_BitacoraVisita import SAMM_BitacoraVisita, SAMM_BitacoraVisitaSchema
from app.models.SAMM_UbiPersona import SAMM_UbiPersona, SAMM_UbiPersonaSchema
from app.models.SAMM_Ubicacion import SAMM_Ubicacion, SAMM_UbicacionSchema
from app.models.SAMM_Usuario import SAMM_Usuario, SAMM_UsuarioSchema
from app.models.Persona import Persona, PersonaSchema
from werkzeug.security import generate_password_hash, check_password_hash
from flask_jwt_extended import create_access_token

from flask import jsonify, request
from flask_cors import cross_origin
from app.visitas import bp
from app.extensions import db
from sqlalchemy import text
import base64
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import date, datetime, timedelta
import time
from sqlalchemy import or_

'''
{
    "date": DateFormat('dd/MM/yyyy').format(_selectedDate),
    "time": _selectedTime.format(context),
    "duration": _selectedDuration,
    "cedula": _idController.text,
    "name": _nameController.text,
    "lastName": _lastNameController.text,

}
'''
@bp.route('/registraVisita', methods=['POST'])
@cross_origin()
@jwt_required()
def registraVisita():
    userName=get_jwt_identity()
    user= SAMM_Usuario.query.filter_by(Codigo=userName).first()
    print(user)
    usuarioPersona = user.IdPersona
    print(usuarioPersona)
    #read estado from request, if none, set to 'P'
    estado = request.json['estado'] if 'estado' in request.json else 'A'

    # get data from persona, check if exists by cedula
    anfitrion = Persona.query.filter_by(Id=usuarioPersona).first()
    print(anfitrion)
    IdAnfitrion=anfitrion.Id
    # check if persona anfritiona exists
    # get data from ubicacion, check if exists by coordinates
    '''coordenadas = request.json['coordenadas']
    ubicacion = SAMM_Ubicacion.query.filter_by(Coordenadas=coordenadas).first()
    if ubicacion is None:
        # create new ubicacion
        ubicacion = SAMM_Ubicacion()
        ubicacion.Codigo = request.json['codigo_ubicacion']
        ubicacion.Coordenadas = coordenadas
        ubicacion.Tipo = request.json['tipo']
        ubicacion.Descripcion = request.json['descripcion_ubicacion']
        ubicacion.Direccion = request.json['direccion']
        ubicacion.UsuarioCrea = user
        ubicacion.UsuarioModifica = user
        ubicacion.FechaCrea = datetime.now()
        ubicacion.FechaModifica = datetime.now()
        db.session.add(ubicacion)
        db.session.commit()'''
    # get data from persona, check if exists by cedula
    visitante = Persona.query.filter_by(Identificacion=request.json['cedula']).first()
    if visitante is None:
        #create new persona
        visitante = Persona()
        visitante.TipoIde= 'CED'
        visitante.Identificacion = request.json['cedula']
        visitante.Nombres = request.json['name']
        visitante.Apellidos = request.json['lastName']
        visitante.UsuarioCrea = user.Id
        visitante.UsuarioModifica = user.Id
        visitante.FechaCrea = datetime.now()
        visitante.FechaModifica = datetime.now()
        #falta visitante placa
        '''visitante.FechaNac= request.json['fecha_nacimiento']
        visitante.Sexo = request.json['sexo']
        visitante.EstadoCivil = request.json['estado_civil']

        visitante.Cargo = request.json['cargo']
        visitante.Dir_Domicilio = request.json['direccion_domicilio']
        visitante.Correo_Domicilio = request.json['correo_domicilio']
        visitante.Cel_Personal = request.json['celular_personal']'''

        db.session.add(visitante)
        db.session.commit()
    idVisitante=visitante.Id
    # look if the visitante is already an user
    usuario = SAMM_Usuario.query.filter_by(IdPersona=idVisitante).first()
    if usuario is None:
        # add a user temp for the visitante

            # create new user
        usuario = SAMM_Usuario()
        usuario.IdPersona = idVisitante
        usuario.Codigo = request.json['cedula']
        usuario.Clave = generate_password_hash(request.json['cedula'], method='sha256')
        usuario.IdPerfil = 2
        usuario.Estado = 'T'
        usuario.FechaCrea = datetime.now()
        usuario.FechaModifica = datetime.now()
        usuario.UsuarioCrea = user.Id
        usuario.UsuarioModifica = user.Id
        usuario.Confirmado='Y'
        usuario.FechaConfirmacion=datetime.now()
        db.session.add(usuario)
        db.session.commit()

    else:
        #activate user
        usuario.Estado = 'T'
        usuario.FechaModifica = datetime.now()
        db.session.commit()

    # check if there is ubicacion in request
    if 'ubicacion' in request.json:
        idUbicacion = request.json['ubicacion']
    else:
        idUbicacion = 1
    # # create new visita
    visita = SAMM_BitacoraVisita()
    visita.Codigo = str(request.json['cedula'])
    visita.Descripcion = 'Visita de ' + request.json['name'] + ' ' + request.json['lastName'] + ' a ' + anfitrion.Nombres + ' ' + anfitrion.Apellidos
    visita.IdAnfitrion = IdAnfitrion
    visita.IdVisita= usuario.Id
    visita.IdUbicacion = idUbicacion
    #transformar fecha de string a date
    #join time and date
    date_time_str = request.json['date'] + ' ' + request.json['time']
    date_time_obj = datetime.strptime(date_time_str, '%Y-%m-%d %H:%M')
    visita.FechaVisita = date_time_obj
    visita.FechaCrea = datetime.now()
    visita.FechaModifica = datetime.now()
    visita.UsuarioCrea = user.Id
    visita.UsuarioModifica = user.Id
    visita.Estado = estado
    visita.Hora = request.json['time']
    visita.Duracion= request.json['duration']
    visita.Placa= request.json['placa']
    # para hora estimada de salida sumarle la duracion a la hora de entrada
    #transformar duracion de horas a minutos
    Duracion= request.json['duration']*60
    FechaSalidaEstimada = date_time_obj + timedelta(minutes=int(Duracion))
    visita.FechaSalidaEstimada = FechaSalidaEstimada
    print(visita)
    db.session.add(visita)
    db.session.commit()

    
    temp_user_dict={
        'Id':usuario.Id,
        'IdPersona':usuario.IdPersona,
        'Nombres':visitante.Nombres,
        'Apellidos':visitante.Apellidos,
        'Codigo':usuario.Codigo,
        'Clave':usuario.Codigo,
        'IdPerfil':usuario.IdPerfil,
        'Estado':usuario.Estado,
        'FechaCrea':usuario.FechaCrea,
        'access_token': create_access_token(identity=usuario.Codigo),
        'UsuarioCrea':usuario.UsuarioCrea,
        'UsuarioModifica':usuario.UsuarioModifica,
        'Confirmado':usuario.Confirmado,
        'FechaConfirmacion':usuario.FechaConfirmacion,
        "visita": {
            'Id':visita.Id,
            'Codigo':visita.Codigo,
            'Descripcion':visita.Descripcion,
            'IdAnfitrion':visita.IdAnfitrion,
            'IdVisita':visita.IdVisita,
            'IdUbicacion':visita.IdUbicacion,
            'FechaVisita':visita.FechaVisita,
            'FechaSalidaEstimada':visita.FechaSalidaEstimada,

        }
    }
    # return the new user and their JWT to the client
    return jsonify(visita=temp_user_dict), 201


# end a visit
@bp.route('/visita/<int:id>', methods=['PUT'])
@cross_origin()
@jwt_required()
def end_visit(id):
    # get the user who is making the request
    user = SAMM_Usuario.query.filter_by(Codigo=get_jwt_identity()).first()
    # check if request have a date and time, if not, use current date and time
    date_time_obj = request.json['date'] if 'date' in request.json else datetime.now()

    # end visit
    visita = SAMM_BitacoraVisita.query.filter_by(Id=id).first()
    visita.FechaSalida = date_time_obj
    visita.FechaModifica = datetime.now()
    visita.UsuarioModifica = user.Id
    visita.Estado = 'F'
    db.session.commit()
    result ={
        'Id':visita.Id,
        'Codigo':visita.Codigo,
        'Descripcion':visita.Descripcion,
        'IdAnfitrion':visita.IdAnfitrion,
        'IdVisita':visita.IdVisita,
        'IdUbicacion':visita.IdUbicacion,
        'FechaVisita':visita.FechaVisita,
        'FechaSalidaEstimada':visita.FechaSalidaEstimada,
        'FechaSalida':visita.FechaSalida,
        'Estado':visita.Estado,
        'Hora':visita.Hora,
        'Duracion':visita.Duracion,
        'Placa':visita.Placa,
        'FechaCrea':visita.FechaCrea,
        'FechaModifica':visita.FechaModifica,
        'UsuarioCrea':visita.UsuarioCrea,
        'UsuarioModifica':visita.UsuarioModifica,
    }

    # return the new user and their JWT to the client
    return jsonify(visita=result), 201

# edit a visit
@bp.route('/cerrarVisita/<int:id>', methods=['GET'])
@cross_origin()
@jwt_required()
def cerrarVisita(id):
    #get the user who is making the request
    user = SAMM_Usuario.query.filter_by(Codigo=get_jwt_identity()).first()
    #use the id to get the visita
    visita = SAMM_BitacoraVisita.query.filter_by(Id=id).first()
    if(visita is None):
        return jsonify({'message': 'Visita no existe'}), 500
    #check if the visita is already closed
    if(visita.Estado=='F'):
        return jsonify({'message': 'Visita ya esta cerrada'}), 500
    visita.FechaSalidaReal=datetime.now()
    visita.FechaModifica=datetime.now()
    visita.UsuarioModifica=user.Id
    if visita.FechaSalidaReal > visita.FechaSalidaEstimada:
        visita.Estado='S'
    else:
        visita.Estado='R'

    db.session.commit()
    result ={
        'Id':visita.Id,
        'Codigo':visita.Codigo,
        'Descripcion':visita.Descripcion,
        'IdAnfitrion':visita.IdAnfitrion,
        'IdVisita':visita.IdVisita,
        'IdUbicacion':visita.IdUbicacion,

        'FechaVisita':visita.FechaVisita,
        'FechaSalidaEstimada':visita.FechaSalidaEstimada,
        'FechaSalida':visita.FechaSalidaReal,
        'Estado':visita.Estado,
        'Hora':visita.Hora,
        'Duracion':visita.Duracion,
        'Placa':visita.Placa,
        'FechaCrea':visita.FechaCrea,
        'FechaModifica':visita.FechaModifica,
        'UsuarioCrea':visita.UsuarioCrea,
        'UsuarioModifica':visita.UsuarioModifica,
    }

    # return the new user and their JWT to the client
    return jsonify(visita=result), 201


# edit a visit
@bp.route('/actualizar/<int:id>', methods=['POST'])
@cross_origin()
@jwt_required()
def edit_visit(id):
    #get the user who is making the request
    user = SAMM_Usuario.query.filter_by(Codigo=get_jwt_identity()).first()
    #use the id to get the visita
    visita = SAMM_BitacoraVisita.query.filter_by(Id=id).first()
    if(visita is None):
        return jsonify({'message': 'Visita no existe'}), 500
    # update the values in visita and save, with for 
    print(request.json)
    for key, value in request.json.items():
        
        setattr(visita, key, value)
    visita.FechaModifica=datetime.now()
    visita.UsuarioModifica=user.Id
    db.session.commit()
    result ={
        'Id':visita.Id,
        'Codigo':visita.Codigo,
        'Descripcion':visita.Descripcion,
        'IdAnfitrion':visita.IdAnfitrion,
        'IdVisita':visita.IdVisita,
        'IdUbicacion':visita.IdUbicacion,
        'FechaVisita':visita.FechaVisita,

        'FechaSalidaEstimada':visita.FechaSalidaEstimada,
        'FechaSalida':visita.FechaSalidaReal,
        'Estado':visita.Estado,
        'Hora':visita.Hora,
        'Duracion':visita.Duracion,

        'Placa':visita.Placa,
        'FechaCrea':visita.FechaCrea,
        'FechaModifica':visita.FechaModifica,
        'UsuarioCrea':visita.UsuarioCrea,
        'UsuarioModifica':visita.UsuarioModifica,
    }

    # return the new user and their JWT to the client
    return jsonify(visita=result), 201