from  app.extensions import db, PrimaryKeyConstraint
from app.extensions import ma

class SAMM_Ubicacion(db.Model):
    __tablename__ = 'SAMM_Ubicacion'
    __table_args__ = {'schema':'SAMM.dbo'}

    Id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    Codigo = db.Column(db.String(30))
    Coordenadas = db.Column(db.String(500))
    Tipo = db.Column(db.String(40))
    FechaCrea = db.Column(db.DateTime)
    UsuarioCrea = db.Column(db.Integer)
    FechaModifica = db.Column(db.DateTime)
    Descripcion = db.Column(db.String(1))
    UsuarioModifica = db.Column(db.Integer)
    Direccion = db.Column(db.String(100))
    Estado = db.Column(db.String(1))
    Propiedades=db.Column(db.Integer)
    SupervisorId=db.Column(db.Integer)

class SAMM_UbicacionSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model=SAMM_Ubicacion