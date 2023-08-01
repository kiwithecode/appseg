from app.extensions import db, PrimaryKeyConstraint
from app.extensions import ma

class SAMM_PuntoRonda(db.Model):
    __tablename__ = 'SAMM_PuntoRonda'
    __table_args__ = {'schema':'SAMM.dbo'}

    Id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    IdRonda = db.Column(db.Integer)
    Orden = db.Column(db.Integer)
    Coordenada = db.Column(db.String(1))
    Estado = db.Column(db.String(1))
    FechaCreacion = db.Column(db.DateTime)
    UsuCreacion = db.Column(db.Integer)
    FechaModificacion = db.Column(db.DateTime)
    UsuModifica = db.Column(db.Integer)

class SAMM_PuntoRondaSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model=SAMM_PuntoRonda