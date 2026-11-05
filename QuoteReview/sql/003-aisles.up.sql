SET XACT_ABORT ON;
SET NOCOUNT ON;
IF DB_NAME() <> N'DAYR_PWA_QUOTE_DEV'
    THROW 51000, 'Select the isolated DAYR_PWA_QUOTE_DEV database.', 1;
BEGIN TRANSACTION;

CREATE TABLE dbo.Pasillos (
    CodigoAlmacen varchar(10) NOT NULL REFERENCES dbo.Almacenes(CodigoAlmacen),
    CodigoPasillo varchar(10) NOT NULL,
    Descripcion nvarchar(150) NOT NULL,
    PRIMARY KEY (CodigoAlmacen, CodigoPasillo)
);

CREATE TABLE dbo.UbicacionesProducto (
    CodigoArticulo varchar(30) NOT NULL,
    CodigoAlmacen varchar(10) NOT NULL,
    CodigoPasillo varchar(10) NOT NULL,
    PRIMARY KEY (CodigoArticulo, CodigoAlmacen),
    FOREIGN KEY (CodigoArticulo, CodigoAlmacen)
        REFERENCES dbo.Existencias(CodigoArticulo, CodigoAlmacen),
    FOREIGN KEY (CodigoAlmacen, CodigoPasillo)
        REFERENCES dbo.Pasillos(CodigoAlmacen, CodigoPasillo)
);
CREATE INDEX IX_UbicacionesProducto_Pasillo
    ON dbo.UbicacionesProducto(CodigoAlmacen, CodigoPasillo, CodigoArticulo);

CREATE TABLE dbo.EncargadosPasillo (
    CodigoAlmacen varchar(10) NOT NULL,
    IdUsuario int NOT NULL REFERENCES dbo.Usuarios(IdUsuario),
    CodigoPasillo varchar(10) NOT NULL,
    PRIMARY KEY (CodigoAlmacen, IdUsuario),
    FOREIGN KEY (CodigoAlmacen, CodigoPasillo)
        REFERENCES dbo.Pasillos(CodigoAlmacen, CodigoPasillo)
);
CREATE INDEX IX_EncargadosPasillo_Pasillo
    ON dbo.EncargadosPasillo(CodigoAlmacen, CodigoPasillo, IdUsuario);
CREATE INDEX IX_EncargadosPasillo_Usuario ON dbo.EncargadosPasillo(IdUsuario);

COMMIT;
