from app.extensions import db, PrimaryKeyConstraint
from app.extensions import ma

class SAMM_Usuario(db.Model):
    __tablename__ = 'SAMM_Usuario'
    __table_args__ = {'schema':'SAMM.dbo'}

    Id = db.Column(db.Integer, primary_key=True)
    Codigo = db.Column(db.String(50))
    Clave = db.Column(db.String(255))
    IdPersona = db.Column(db.Integer)
    IdPerfil = db.Column(db.Integer)
    Estado = db.Column(db.String(1))
    FechaCrea = db.Column(db.DateTime)
    UsuarioCrea = db.Column(db.Integer)
    FechaModifica = db.Column(db.DateTime)
    UsuarioModifica = db.Column(db.Integer)
    FechaUltimoLogin = db.Column(db.DateTime)
    Confirmado = db.Column(db.String(1))
    FechaConfirmacion = db.Column(db.DateTime)
    Pin= db.Column(db.String(4))

class SAMM_UsuarioSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model=SAMM_Usuario