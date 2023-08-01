from app.extensions import db, PrimaryKeyConstraint
from app.extensions import ma

class SAMM_RondaAsignacion(db.Model):
    __tablename__ = 'SAMM_RondaAsignacion'
    __table_args__ = {'schema':'SAMM.dbo'}

    Id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    IdAsignado = db.Column(db.Integer)
    IdRonda = db.Column(db.Integer)
    Estado = db.Column(db.String(1))
    IdUbicacion = db.Column(db.Integer)


class SAMM_RondaAsignacionSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model=SAMM_RondaAsignacion