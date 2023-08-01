from email.message import EmailMessage
import os
import random
import ssl
import string
from app.models.Persona import Persona
from flask import request, jsonify
from flask_jwt_extended import create_access_token
from app.extensions import db
from app.login import bp as app
from marshmallow import ValidationError
from werkzeug.security import check_password_hash
from flask_cors import cross_origin
from datetime import timedelta
from app.models.SAMM_Usuario import SAMM_Usuario, SAMM_UsuarioSchema

from flask import jsonify, request
from flask_cors import cross_origin
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import date, datetime
import smtplib
from werkzeug.security import generate_password_hash, check_password_hash

@app.route('/login', methods=['POST'])
@cross_origin()
def login():
    try:
        data = request.get_json()
        if not data:
            return jsonify({'message': 'No input data provided'}), 400
        Codigo = data.get('Codigo')
        Pin= data.get('Pin')
        Clave = data.get('Clave')
        if not Codigo:
            return jsonify({'message': 'No Codigo provided'}), 400
        if not Clave and not Pin:
            return jsonify({'message': 'No Clave or Pin provided'}), 400
        usuario = SAMM_Usuario.query.filter_by(Codigo=Codigo).first()
        if not usuario:
            return jsonify({'message': 'Usuario no existe'}), 400
        if Pin and not (usuario.Pin == Pin):
            return jsonify({'message': 'Pin incorrecto'}), 400
        if Clave and not check_password_hash(usuario.Clave, Clave):
            return jsonify({'message': 'Contraseña incorrecta'}), 400
        if usuario.Estado != 'A' and usuario.Estado != 'T':
            return jsonify({'message': 'Usuario inactivo'}), 400
        if usuario.Confirmado == 'N':
            return jsonify({'message': 'Usuario no confirmado'}), 400
        
        #check if data request has a web field
        if 'web' in data:
            if data['web'] == True:
                if usuario.IdPerfil == 2 or usuario.IdPerfil == 3:
                    return jsonify({'message': 'Usuario no autorizado'}), 400	
        
        expires = timedelta(hours=120)
        #change the fechaultimologin of the user
        usuario.Fechaultimologin = datetime.now()
        user=SAMM_UsuarioSchema().dump(usuario)
        access_token = create_access_token(identity=usuario.Codigo, expires_delta=expires)
        return jsonify(access_token=access_token, usuario=user), 200
    except Exception as e:
        return jsonify({'message': str(e)}), 500
    

@app.route('/loginPin', methods=['POST'])
@cross_origin()
def loginPin():
    data=request.get_json()
    if not data:
        return jsonify({'message': 'No input data provided'}), 400
    pin=data.get('Pin')
    if not pin:
        return jsonify({'message': 'No Pin provided'}), 400
    usuario = SAMM_Usuario.query.filter_by(Pin=pin).first()
    if not usuario:
        return jsonify({'message': 'Usuario no existe'}), 400
    if usuario.Estado != 'A' and usuario.Estado != 'T':
        return jsonify({'message': 'Usuario inactivo'}), 400
    if usuario.Confirmado == 'N':
        return jsonify({'message': 'Usuario no confirmado'}), 400
    expires = timedelta(hours=120)
    #change the fechaultimologin of the user
    usuario.Fechaultimologin = datetime.now()
    user=SAMM_UsuarioSchema().dump(usuario)
    access_token = create_access_token(identity=usuario.Codigo, expires_delta=expires)
    return jsonify(access_token=access_token, usuario=user), 200

def send_email(email_destinatario, email_asunto, email_mensaje):
    email_address = os.getenv('EMAIL_SENDER')
    email_password = os.getenv('EMAIL_SENDER_PASSWORD')
    email_server= os.getenv('EMAIL_SERVER')
    email_port = os.getenv('EMAIL_PORT')
    #email_destinatario = request.json.get('email_destinatario')
    #email_asunto = request.json.get('email_asunto')
    #email_mensaje = request.json.get('email_mensaje')
    
    msg = EmailMessage()
    msg['Subject'] = email_asunto
    msg['From'] = email_address
    msg['To'] = email_destinatario
    msg.set_content(email_mensaje)

    context = ssl.create_default_context()

    with smtplib.SMTP_SSL(email_server, email_port, context=context) as server:
        server.login(email_address, email_password)
        server.sendmail(email_address, email_destinatario, msg.as_string())
    
    return jsonify({'message': 'Email enviado'}), 200

@app.route('/recuperarClave', methods=['POST'])
@cross_origin()
def forgotPassword():
    data=request.get_json()
    if not data:
        return jsonify({'message': 'No input data provided'}), 400
    email=data.get('email')
    if not email:
        return jsonify({'message': 'No email provided'}), 400
    usuario = Persona.query.filter_by(Correo_Domicilio=email).first()
    if not usuario:
        return jsonify({'message': 'Usuario no existe'}), 400
    if usuario.Estado != 'A' and usuario.Estado != 'T':
        return jsonify({'message': 'Usuario inactivo'}), 400
    if usuario.Confirmado == 'N':
        return jsonify({'message': 'Usuario no confirmado'}), 400
    
    #generate a random code to send in the verification email
    code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
    #hash the code
    hashed_code = generate_password_hash(code)
    #add the code to the user
    usuario.Clave=hashed_code
    db.session.commit()
    mensaje=f'''
    ¡Bienvenido a SAMM!\n
    Usa el siguiente código para cambiar tu contraseña:\n
    {code}\n
    '''
    send_email(email, "Código de verificación", mensaje)
    return jsonify({'message': 'Email enviado'}), 200

@app.route('/recuperarPin', methods=['POST'])
@cross_origin()
def forgotPin():
    data=request.get_json()
    if not data:
        return jsonify({'message': 'No input data provided'}), 400
    email=data.get('email')
    if not email:
        return jsonify({'message': 'No email provided'}), 400
    usuario = Persona.query.filter_by(Correo_Domicilio=email).first()
    if not usuario:
        return jsonify({'message': 'Usuario no existe'}), 400
    if usuario.Estado != 'A' and usuario.Estado != 'T':
        return jsonify({'message': 'Usuario inactivo'}), 400
    if usuario.Confirmado == 'N':
        return jsonify({'message': 'Usuario no confirmado'}), 400
    expires = timedelta(hours=120)
    #change the fechaultimologin of the user
    usuario.Fechaultimologin = datetime.now()
    user=SAMM_UsuarioSchema().dump(usuario)
    access_token = create_access_token(identity=usuario.Codigo, expires_delta=expires)
    return jsonify(access_token=access_token, usuario=user), 200

@app.route('/changePassword', methods=['POST'])
@cross_origin()
@jwt_required()
def changePassword():
    data=request.get_json()
    if not data:
        return jsonify({'message': 'No input data provided'}), 400
    password=data.get('password')
    if not password:
        return jsonify({'message': 'No password provided'}), 400
    usuario = SAMM_Usuario.query.filter_by(Codigo=get_jwt_identity()).first()
    if not usuario:
        return jsonify({'message': 'Usuario no existe'}), 400
    if usuario.Estado != 'A' and usuario.Estado != 'T':
        return jsonify({'message': 'Usuario inactivo'}), 400
    if usuario.Confirmado == 'N':
        return jsonify({'message': 'Usuario no confirmado'}), 400
    #hash the password
    usuario.Clave=generate_password_hash(password)
    db.session.commit()
    return jsonify({'message': 'Contraseña cambiada exitosamente'}), 200