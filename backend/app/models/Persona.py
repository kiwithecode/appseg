from app.extensions import db, PrimaryKeyConstraint
from app.extensions import ma

class Persona(db.Model):
    __tablename__ = 'Persona'
    __table_args__ = {'schema':'SAMM.dbo'}
    
    Id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    TipoIde = db.Column(db.String(3))
    Identificacion = db.Column(db.String(20))
    Nombres = db.Column(db.String(100))
    Apellidos = db.Column(db.String(100))
    FechaNac = db.Column(db.Date)
    EstadoCivil = db.Column(db.String(15))
    Sexo = db.Column(db.String(1))
    FechaCrea = db.Column(db.DateTime)
    UsuarioCrea = db.Column(db.Integer)
    FechaModifica = db.Column(db.DateTime)
    UsuarioModifica = db.Column(db.Integer)
    Tel_Domicilio = db.Column(db.String(20))
    Tel_Trabajo = db.Column(db.String(20))
    Correo_Domicilio = db.Column(db.String(100))
    Correo_Trabajo = db.Column(db.String(100))
    Dir_Domicilio = db.Column(db.String(100))
    Dir_Trabajo = db.Column(db.String(100))
    Cel_Personal = db.Column(db.String(20))
    Cel_Trabajo = db.Column(db.String(20))
    Cargo = db.Column(db.String(100))
    Foto= db.Column(db.Text())
    NombreFoto= db.Column(db.Text())
    Mimetype= db.Column(db.Text())
    IdRol= db.Column(db.Integer)
    Estado = db.Column(db.String(1))

    #serialize
    
    def serialize(self):
        return {
            'Id': self.Id,
            'TipoIde': self.TipoIde,
            'Identificacion': self.Identificacion,
            'Nombres': self.Nombres,
            'Apellidos': self.Apellidos,
            'FechaNac': self.FechaNac,
            'EstadoCivil': self.EstadoCivil,
            'Sexo': self.Sexo,
            'FechaCrea': self.FechaCrea,
            'UsuarioCrea': self.UsuarioCrea,
            'FechaModifica': self.FechaModifica,
            'UsuarioModifica': self.UsuarioModifica,
            'Tel_Domicilio': self.Tel_Domicilio,
            'Tel_Trabajo': self.Tel_Trabajo,
            'Correo_Domicilio': self.Correo_Domicilio,
            'Correo_Trabajo': self.Correo_Trabajo,
            'Dir_Domicilio': self.Dir_Domicilio,
            'Dir_Trabajo': self.Dir_Trabajo,
            'Cel_Personal': self.Cel_Personal,
            'Cel_Trabajo': self.Cel_Trabajo,
            'Cargo': self.Cargo
        }


class PersonaSchema(ma.SQLAlchemyAutoSchema):
    
    class Meta:
        model = Persona