from app.extensions import db, PrimaryKeyConstraint
from app.extensions import ma

class SAMM_UbiPersona(db.Model):
    __tablename__ = 'SAMM_UbiPersona'
    __table_args__ = {'schema':'SAMM.dbo'}

    Id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    IdPersona = db.Column(db.Integer)
    IdUbicacion = db.Column(db.Integer)

class SAMM_UbiPersonaSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model=SAMM_UbiPersona
    