from app.extensions import db, PrimaryKeyConstraint
from app.extensions import ma

class SAMM_OpRol(db.Model):
    __tablename__ = 'SAMM_OpRol'
    __table_args__ = {'schema':'SAMM.dbo'}

    Id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    idRol = db.Column(db.Integer)
    IdOpcion = db.Column(db.Integer)
    FechaCreacion = db.Column(db.DateTime)
    UsuarioCreacion = db.Column(db.Integer)

class SAMM_OpRolSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model=SAMM_OpRol