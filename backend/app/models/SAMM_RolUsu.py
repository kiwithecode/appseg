from app.extensions import db, PrimaryKeyConstraint
from app.extensions import ma

class SAMM_RolUsu(db.Model):
    __tablename__ = 'SAMM_RolUsu'
    __table_args__ = {'schema':'SAMM.dbo'}

    Id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    idUsuario = db.Column(db.Integer)
    IdRol = db.Column(db.Integer)
    FechaCreacion = db.Column(db.DateTime)
    UsuarioCreacion = db.Column(db.Integer)

class SAMM_RolUsuSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model=SAMM_RolUsu