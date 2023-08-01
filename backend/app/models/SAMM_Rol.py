from app.extensions import db, PrimaryKeyConstraint
from app.extensions import ma

class SAMM_Rol(db.Model):
    __tablename__ = 'SAMM_Rol'
    __table_args__ = {'schema':'SAMM.dbo'}

    Id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    Codigo = db.Column(db.String(1))
    Estado = db.Column(db.String(1))
    FechaCrea = db.Column(db.DateTime)
    UsuarioCrea = db.Column(db.Integer)
    FechaModifica = db.Column(db.DateTime)
    UsuarioModifica = db.Column(db.Integer)
    FechaUltimoLogin = db.Column(db.DateTime)
    Descripcion = db.Column(db.String(1))

class SAMM_RolSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model=SAMM_Rol