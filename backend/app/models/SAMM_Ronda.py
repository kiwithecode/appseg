from app.extensions import db, PrimaryKeyConstraint
from app.extensions import ma

class SAMM_Ronda(db.Model):
    __tablename__ = 'SAMM_Ronda'
    __table_args__ = {'schema':'SAMM.dbo'}

    Id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    Desripcion = db.Column(db.String(255))
    PuntoInicial = db.Column(db.Integer)
    PuntoFinal = db.Column(db.Integer)
    Estado = db.Column(db.String(1))
    IdUbicacion = db.Column(db.Integer)
    FechaCreacion = db.Column(db.DateTime)
    UsuCreacion = db.Column(db.Integer)
    FechaModifica = db.Column(db.DateTime)
    UsuModifica = db.Column(db.Integer)

class SAMM_RondaSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model=SAMM_Ronda