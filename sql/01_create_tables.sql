SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF OBJECT_ID(N'dbo.ubicacion', N'U') IS NULL
CREATE TABLE dbo.ubicacion (
    ubicacion_id INT NOT NULL PRIMARY KEY,
    departamento NVARCHAR(150) COLLATE Latin1_General_100_BIN2 NOT NULL,
    provincia NVARCHAR(150) COLLATE Latin1_General_100_BIN2 NOT NULL,
    distrito NVARCHAR(150) COLLATE Latin1_General_100_BIN2 NOT NULL,
    CONSTRAINT uq_ubicacion UNIQUE (departamento, provincia, distrito)
);
IF OBJECT_ID(N'dbo.biblioteca', N'U') IS NULL
CREATE TABLE dbo.biblioteca (
    registro_id CHAR(64) NOT NULL PRIMARY KEY,
    nombre_biblioteca NVARCHAR(500) NOT NULL,
    tipo_biblioteca NVARCHAR(250) NOT NULL,
    entidad_responsable NVARCHAR(500) NULL,
    ubicacion_id INT NOT NULL REFERENCES dbo.ubicacion(ubicacion_id),
    hoja_origen NVARCHAR(128) NOT NULL,
    fila_origen INT NOT NULL,
    datos_originales NVARCHAR(MAX) NOT NULL,
    CONSTRAINT ck_datos_json CHECK (ISJSON(datos_originales) = 1)
);
COMMIT;
GO
CREATE OR ALTER VIEW dbo.vw_bibliotecas AS
SELECT b.registro_id, b.nombre_biblioteca, b.tipo_biblioteca,
       b.entidad_responsable, u.departamento, u.provincia, u.distrito,
       b.hoja_origen, b.fila_origen
FROM dbo.biblioteca b
JOIN dbo.ubicacion u ON u.ubicacion_id = b.ubicacion_id;
GO
