from app.extensions import db, PrimaryKeyConstraint
from app.extensions import ma
import datetime

class SAMM_BitacoraVisita(db.Model):
    __tablename__ = 'SAMM_BitacoraVisita'
    __table_args__ = {'schema':'SAMM.dbo'}

    Id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    Codigo = db.Column(db.String(30))
    Descripcion = db.Column(db.String(200))
    IdAnfitrion = db.Column(db.Integer)
    IdVisita = db.Column(db.Integer)
    FechaVisita = db.Column(db.DateTime)
    FechaCrea = db.Column(db.DateTime)
    UsuarioCrea = db.Column(db.Integer)
    FechaModifica = db.Column(db.DateTime)
    UsuarioModifica = db.Column(db.Integer)
    Estado = db.Column(db.String(1))
    Observaciones = db.Column(db.String(300))
    IdUbicacion = db.Column(db.Integer)
    Duracion = db.Column(db.Integer)
    Hora = db.Column(db.String(50))
    Placa = db.Column(db.String(50))
    FechaSalidaEstimada = db.Column(db.DateTime)
    FechaSalidaReal = db.Column(db.DateTime)



class SAMM_BitacoraVisitaSchema(ma.SQLAlchemyAutoSchema):

    class Meta:
        model=SAMM_BitacoraVisita