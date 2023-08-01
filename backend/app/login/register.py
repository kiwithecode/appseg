import os
from app.models.SAMM_Rol import SAMM_Rol
from flask import request, jsonify
from flask_jwt_extended import jwt_required, create_access_token
from app.extensions import db
from app.models.SAMM_Usuario import SAMM_Usuario, SAMM_UsuarioSchema
from app.models.SAMM_RolUsu import SAMM_RolUsu, SAMM_RolUsuSchema
from app.models.SAMM_UbiPersona import SAMM_UbiPersona, SAMM_UbiPersonaSchema
from app.models.Persona import Persona, PersonaSchema
from app.login import bp as app
from marshmallow import ValidationError
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
from flask_cors import cross_origin
import datetime
from app.login.login import send_email
'''
{
    "usuario": "amigo",
    "contrasenia": "abc123",
    "cedula": "1234567890"
}

'''
@app.route('/registerTemp', methods=['POST'])
@cross_origin()
def register():
    # use the schema to load the data from the request
    cedula = request.form['cedula']
    #rol by default is 2, which is 'Usuario' or its requested by the user
    rol = request.form['rol'] if 'rol' in request.form else 1
    OnlyPersona = request.form['OnlyPersona'] if 'OnlyPersona' in request.form else False
    # check if cedula exists in CCG_Persona
    existing_cedula = Persona.query.filter_by(Identificacion=cedula).first()
    print(existing_cedula)
    if existing_cedula is None:
        # create new CCG_Persona
        try:
            persona = Persona(
                Identificacion=request.form['cedula'],
                TipoIde=request.form['tipoIde'],
                Nombres=request.form['nombre'],
                Apellidos=request.form['apellido'],
                UsuarioCrea=1,
                FechaCrea=datetime.datetime.now(),
                FechaModifica=datetime.datetime.now(),
                UsuarioModifica=1,
                IdRol=rol,
                Estado='A'
            )
            #iterate through other fields
            for key in request.form:
                if key not in ['cedula', 'tipoIde', 'nombre', 'apellido', 'usuario', 'contrasenia', 'rol']:
                    setattr(persona, key, request.form[key])
            # add new persona to the database
            db.session.add(persona)
            db.session.commit()
            existing_cedula = persona
        except ValidationError as err:
            return jsonify(err), 400
            #check if there is foto in the request
    if 'foto' in request.files:
        foto=request.files['foto']
        #check if there is a foto in the request
        if foto.filename != '':
            filename=secure_filename(foto.filename)
            mimetype=foto.mimetype
            # add new foto to the persona
            try:
                existing_cedula.Foto=foto.read()
                existing_cedula.NombreFoto=filename
                existing_cedula.Mimetype=mimetype
                db.session.commit()
            except ValidationError as err:
                return jsonify(err.messages), 400
    if OnlyPersona is False:
        # get id of CCG_Persona from cedula
        id_persona = existing_cedula.Id
        # check if id_persona exists in CCG_Usuario
        existing_id_persona = SAMM_Usuario.query.filter_by(IdPersona=id_persona).first()
        if existing_id_persona is not None:
            return jsonify({'message': 'El usuario ya existe'}), 400
        
        # check if username exists in CCG_Usuario
        existing_username = SAMM_Usuario.query.filter_by(Codigo=request.form['usuario']).first()
        print(existing_username)
        if existing_username is not None:
            return jsonify({'message': 'Nombre de usuario ya registrado'}), 400

        try:
            user = SAMM_Usuario(
                IdPersona=id_persona,
                Codigo=request.form['usuario'],
                Clave=request.form['contrasenia'],
                Estado='A',
                IdPerfil=rol,
                FechaCrea=datetime.datetime.now(),
                FechaModifica=datetime.datetime.now(),
                FechaUltimoLogin=datetime.datetime.now(),
                Confirmado='N'
            )

            # add new user to the database
            db.session.add(user)
            db.session.commit()
        except ValidationError as err:
            return jsonify(err.messages), 400
        

        # hash the user's password
        password = user.Clave
        hashed_password = generate_password_hash(password)
        user.Clave = hashed_password

        # add new user to the database
        db.session.add(user)
        db.session.commit()
        server_url=os.environ.get('SERVER_URL')
        mensaje=f'''
        ¡Bienvenido a SAMM!\n
        Para confirmar tu cuenta, por favor haz click en el siguiente enlace:\n
        {server_url}login/confirmar/{user.Id}\n
        '''
        #check if there is correo in the request
        if 'correo' in request.form:
            correo=request.form['correo']
            #check if there is a correo in the request
            if correo != '':
                persona.Correo_Domicilio=correo
                db.session.commit()
            send_email(correo, "Código de verificación", mensaje)
        else:
            user.Confirmado='S'
            user.FechaConfirmacion=datetime.datetime.now()
            db.session.commit()

        # create a new JWT for the user
        access_token = create_access_token(identity=user.Codigo)
        user_dict={
            'id': user.Id,
            'IdPersona': user.IdPersona,
            'Codigo': user.Codigo,
            'Estado': user.Estado,
            'IdPerfil': user.IdPerfil,
            'FechaCrea': user.FechaCrea,
            'FechaModifica': user.FechaModifica,
            'FechaUltimoLogin': user.FechaUltimoLogin,
            'Confirmado': user.Confirmado
        }
    # return the new user and their JWT to the client
        return jsonify(access_token=access_token, user=user_dict), 201
    
    else:
        return jsonify({'message': 'Persona creada con éxito'}), 201


@app.route('/getImagen/<id>', methods=['GET'])
@cross_origin()
def getImagen(id):
    # check if cedula exists in CCG_Persona
    existing_cedula = Persona.query.filter_by(Id=id).first()
    if existing_cedula is None:
        return jsonify({'message': 'La persona no existe'}), 400
    
    #check if there is foto in the request
    if existing_cedula.Foto is None:
        return jsonify({'message': 'La persona no tiene foto'}), 400
    else:
        return existing_cedula.Foto, 200, {'Content-Type': existing_cedula.Mimetype, 'Content-Disposition': 'inline; filename=%s' % existing_cedula.NombreFoto}
    

@app.route('/confirmar/<id>', methods=['GET'])
@cross_origin()
def confirmar(id):
    user= SAMM_Usuario.query.filter_by(IdPersona=id).first()
    if user is None:
        return jsonify({'message': 'Usuario no existe'}), 400
    user.Confirmado='S'
    db.session.commit()
    return jsonify({'message': 'Usuario confirmado exitosamente'}), 200