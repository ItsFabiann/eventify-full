USE master;
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'EventifyDB')
    DROP DATABASE EventifyDB;
GO

CREATE DATABASE EventifyDB;
GO

USE EventifyDB;
GO

CREATE TABLE Usuarios (
    UsuarioId INT IDENTITY(1,1) PRIMARY KEY,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    NombreCompleto NVARCHAR(100) NOT NULL,
    Dni NVARCHAR(20) NULL,
    Telefono NVARCHAR(20) NULL,
    Rol NVARCHAR(20) NOT NULL CHECK (Rol IN ('Admin', 'Organizador', 'Comprador')),
    FechaCreacion DATETIME DEFAULT GETDATE(),
    Activo BIT DEFAULT 1,
    CONSTRAINT CK_Usuario_Dni CHECK (
      (Rol = 'Admin' AND Dni IS NULL) OR
      (Rol IN ('Organizador', 'Comprador') AND Dni IS NOT NULL AND LEN(Dni) >= 8)
    )
);
GO

CREATE TABLE Eventos (
    EventoId INT IDENTITY(1,1) PRIMARY KEY,
    Titulo NVARCHAR(200) NOT NULL,
    Descripcion NVARCHAR(500),
    FechaEvento DATETIME NOT NULL,
    Ubicacion NVARCHAR(200) NOT NULL,
    Capacidad INT NOT NULL DEFAULT 1000,
    AsientosDisponibles INT NOT NULL DEFAULT 1000,
    Categoria NVARCHAR(50) NOT NULL CHECK (Categoria IN ('Cultural', 'Empresarial', 'Virtual')),
    OrganizadorId INT NOT NULL,
    Precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    Imagen NVARCHAR(500) NULL,
    EstadoEvento NVARCHAR(20) NOT NULL DEFAULT 'Activo' CHECK (EstadoEvento IN ('Activo', 'Cancelado', 'Finalizado')),
    FechaCreacion DATETIME DEFAULT GETDATE(),
    FechaModificacion DATETIME NULL,
    FOREIGN KEY (OrganizadorId) REFERENCES Usuarios(UsuarioId) ON DELETE CASCADE
);
GO

CREATE INDEX IX_Eventos_Categoria ON Eventos(Categoria);
CREATE INDEX IX_Eventos_Precio ON Eventos(Precio);
CREATE INDEX IX_Eventos_FechaEvento ON Eventos(FechaEvento);
CREATE INDEX IX_Eventos_Titulo_Descripcion ON Eventos(Titulo, Descripcion);
GO

CREATE TABLE Boletos (
    BoletoId INT IDENTITY(1,1) PRIMARY KEY,
    EventoId INT NOT NULL,
    UsuarioId INT NOT NULL,
    TipoBoleto NVARCHAR(50) NOT NULL,
    NumeroBoleto NVARCHAR(50) UNIQUE,
    Cantidad INT NOT NULL DEFAULT 1,
    Precio DECIMAL(10,2) NOT NULL,
    CodigoQR NVARCHAR(255),
    Estado NVARCHAR(20) NOT NULL DEFAULT 'Disponible' CHECK (Estado IN ('Disponible', 'Comprado', 'Usado', 'Cancelado')),
    FechaCompra DATETIME DEFAULT GETDATE(),
    FechaModificacion DATETIME NULL,
    FOREIGN KEY (EventoId) REFERENCES Eventos(EventoId) ON DELETE CASCADE,
    FOREIGN KEY (UsuarioId) REFERENCES Usuarios(UsuarioId) ON DELETE NO ACTION
);
GO

CREATE INDEX IX_Boletos_EventoId ON Boletos(EventoId);
CREATE INDEX IX_Boletos_UsuarioId ON Boletos(UsuarioId);
GO

CREATE TABLE Pagos (
    PagoId INT IDENTITY(1,1) PRIMARY KEY,
    BoletoId INT NOT NULL,
    Monto DECIMAL(10,2) NOT NULL,
    Comision DECIMAL(10,2) DEFAULT 0.00,
    MetodoPago NVARCHAR(50) NOT NULL CHECK (MetodoPago IN ('TarjetaDebito', 'Yape', 'Plin', 'Culqi', 'PayPal', 'Efectivo')),
    IdTransaccion NVARCHAR(100),
    Estado NVARCHAR(20) NOT NULL DEFAULT 'Pendiente' CHECK (Estado IN ('Pendiente', 'Exitoso', 'Fallido')),
    FechaPago DATETIME DEFAULT GETDATE(),
    FechaModificacion DATETIME NULL,
    FOREIGN KEY (BoletoId) REFERENCES Boletos(BoletoId) ON DELETE CASCADE
);
GO

CREATE TABLE Comentarios (
    ComentarioId INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioId INT NOT NULL,
    Mensaje NVARCHAR(MAX) NOT NULL,
    FechaEnvio DATETIME DEFAULT GETDATE(),
    Eliminado BIT DEFAULT 0,
    FOREIGN KEY (UsuarioId) REFERENCES Usuarios(UsuarioId) ON DELETE CASCADE
);
GO

CREATE INDEX IX_Comentarios_UsuarioId ON Comentarios(UsuarioId);
CREATE INDEX IX_Comentarios_FechaEnvio ON Comentarios(FechaEnvio);
GO
