from app.extensions import db, PrimaryKeyConstraint
from app.extensions import ma
from datetime import datetime

class SAMM_PropiedadAgente(db.Model):
    __tablename__ = 'SAMM_PropiedadAgente'
    __table_args__ = {'schema':'SAMM.dbo'}

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    create_time = db.Column(db.DateTime, default=datetime.now())
    update_time = db.Column(db.DateTime, default=datetime.now())
    content = db.Column(db.String(255))
    idPropiedad = db.Column(db.Integer)
    idAgente = db.Column(db.Integer)

class SAMM_PropiedadAgenteSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model=SAMM_PropiedadAgente
