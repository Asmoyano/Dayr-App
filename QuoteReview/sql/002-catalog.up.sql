SET XACT_ABORT ON;
SET NOCOUNT ON;
IF DB_NAME() <> N'DAYR_PWA_QUOTE_DEV'
    THROW 51000, 'Select the isolated DAYR_PWA_QUOTE_DEV database.', 1;
BEGIN TRANSACTION;

CREATE TABLE dbo.AccesoVendedor (
    Emisor nvarchar(200) COLLATE Latin1_General_100_BIN2 NOT NULL,
    Sujeto nvarchar(200) COLLATE Latin1_General_100_BIN2 NOT NULL,
    CodigoVendedor varchar(30) NOT NULL REFERENCES dbo.Vendedores(CodigoVendedor),
    PRIMARY KEY (Emisor, Sujeto)
);

CREATE TABLE dbo.ListasPrecio (
    IdLista int IDENTITY PRIMARY KEY,
    Codigo varchar(30) NOT NULL,
    Moneda char(3) COLLATE Latin1_General_100_BIN2 NOT NULL CHECK (Moneda LIKE '[A-Z][A-Z][A-Z]'),
    UNIQUE (Codigo, Moneda)
);

CREATE TABLE dbo.AccesoClienteVendedor (
    CodigoVendedor varchar(30) NOT NULL REFERENCES dbo.Vendedores(CodigoVendedor),
    CodigoCliente varchar(30) NOT NULL REFERENCES dbo.Clientes(CodigoCliente),
    IdLista int NOT NULL REFERENCES dbo.ListasPrecio(IdLista),
    PRIMARY KEY (CodigoVendedor, CodigoCliente, IdLista)
);

CREATE TABLE dbo.AccesoProductoVendedor (
    CodigoVendedor varchar(30) NOT NULL REFERENCES dbo.Vendedores(CodigoVendedor),
    CodigoArticulo varchar(30) NOT NULL REFERENCES dbo.Productos(CodigoArticulo),
    PRIMARY KEY (CodigoVendedor, CodigoArticulo)
);

CREATE TABLE dbo.PreciosCatalogo (
    IdLista int NOT NULL REFERENCES dbo.ListasPrecio(IdLista),
    CodigoArticulo varchar(30) NOT NULL REFERENCES dbo.Productos(CodigoArticulo),
    PrecioUnitarioNeto decimal(19,4) NOT NULL CHECK (PrecioUnitarioNeto >= 0),
    VigenteDesdeUtc datetime2(3) NOT NULL,
    VigenteHastaUtc datetime2(3) NULL,
    VersionOrigen nvarchar(100) NOT NULL,
    RegistradoUtc datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
    PRIMARY KEY (IdLista, CodigoArticulo, VigenteDesdeUtc),
    CHECK (VigenteHastaUtc > VigenteDesdeUtc OR VigenteHastaUtc IS NULL)
);

CREATE INDEX IX_PreciosCatalogo_Articulo ON dbo.PreciosCatalogo(CodigoArticulo, IdLista);
CREATE INDEX IX_AccesoCliente_Cliente ON dbo.AccesoClienteVendedor(CodigoCliente, IdLista);
CREATE INDEX IX_AccesoCliente_Lista ON dbo.AccesoClienteVendedor(IdLista);
CREATE INDEX IX_AccesoProducto_Articulo ON dbo.AccesoProductoVendedor(CodigoArticulo);
CREATE INDEX IX_AccesoVendedor_Vendedor ON dbo.AccesoVendedor(CodigoVendedor);

CREATE TABLE dbo.ConfiguracionCotizacion (
    Id tinyint NOT NULL PRIMARY KEY CHECK (Id = 1),
    ValidarStock bit NOT NULL DEFAULT 0 CHECK (ValidarStock = 0)
);
INSERT dbo.ConfiguracionCotizacion (Id) VALUES (1);

CREATE ROLE dayr_catalog_api;
EXEC(N'
CREATE PROCEDURE dbo.LeerCatalogoCotizacion
    @Emisor nvarchar(200),
    @Sujeto nvarchar(200),
    @CodigoCliente varchar(30) = NULL,
    @DespuesDe varchar(30) = NULL,
    @Limite int = 50
AS
BEGIN
    SET NOCOUNT ON;
    IF @Limite IS NULL OR @Limite NOT BETWEEN 1 AND 100
        THROW 51001, ''Invalid page size.'', 1;

    DECLARE @Vendedor varchar(30);
    SELECT @Vendedor = a.CodigoVendedor
    FROM dbo.AccesoVendedor a
    JOIN dbo.Vendedores v ON v.CodigoVendedor = a.CodigoVendedor AND v.Estado = ''VIGENTE''
    WHERE a.Emisor = @Emisor AND a.Sujeto = @Sujeto
      AND DATALENGTH(a.Emisor) = DATALENGTH(@Emisor)
      AND DATALENGTH(a.Sujeto) = DATALENGTH(@Sujeto);

    IF @CodigoCliente IS NULL
    BEGIN
        SELECT TOP (@Limite) c.CodigoCliente, c.NombreRazonSocial
        FROM dbo.Clientes c
        WHERE c.Estado = ''VIGENTE''
          AND (@DespuesDe IS NULL OR c.CodigoCliente > @DespuesDe)
          AND EXISTS (SELECT 1 FROM dbo.AccesoClienteVendedor a
                      WHERE a.CodigoVendedor = @Vendedor AND a.CodigoCliente = c.CodigoCliente)
        ORDER BY c.CodigoCliente;
        RETURN;
    END;

    DECLARE @Ahora datetime2(3) = SYSUTCDATETIME();
    WITH Pagina AS (
        SELECT TOP (@Limite) p.CodigoArticulo, p.Descripcion, p.CodigoUnidad, p.PermiteDecimal
        FROM dbo.AccesoProductoVendedor a
        JOIN dbo.Productos p ON p.CodigoArticulo = a.CodigoArticulo AND p.Estado = ''VIGENTE''
        WHERE a.CodigoVendedor = @Vendedor
          AND (@DespuesDe IS NULL OR p.CodigoArticulo > @DespuesDe)
          AND EXISTS (
              SELECT 1 FROM dbo.AccesoClienteVendedor ac
              JOIN dbo.Clientes c ON c.CodigoCliente = ac.CodigoCliente AND c.Estado = ''VIGENTE''
              WHERE ac.CodigoVendedor = @Vendedor AND ac.CodigoCliente = @CodigoCliente
                AND EXISTS (
                    SELECT 1 FROM dbo.PreciosCatalogo pr
                    WHERE pr.IdLista = ac.IdLista AND pr.CodigoArticulo = p.CodigoArticulo
                      AND pr.VigenteDesdeUtc <= @Ahora
                      AND (pr.VigenteHastaUtc IS NULL OR pr.VigenteHastaUtc > @Ahora)))
        ORDER BY p.CodigoArticulo
    )
    SELECT p.CodigoArticulo, p.Descripcion, p.CodigoUnidad, p.PermiteDecimal,
           l.Codigo AS Lista, l.Moneda, pr.PrecioUnitarioNeto, pr.VersionOrigen,
           pr.VigenteDesdeUtc, pr.VigenteHastaUtc, @Ahora AS ConsultadoUtc
    FROM Pagina p
    JOIN dbo.AccesoClienteVendedor ac
      ON ac.CodigoVendedor = @Vendedor AND ac.CodigoCliente = @CodigoCliente
    JOIN dbo.ListasPrecio l ON l.IdLista = ac.IdLista
    CROSS APPLY (
        SELECT TOP (1) pr.PrecioUnitarioNeto, pr.VersionOrigen, pr.VigenteDesdeUtc, pr.VigenteHastaUtc
        FROM dbo.PreciosCatalogo pr
        WHERE pr.IdLista = l.IdLista AND pr.CodigoArticulo = p.CodigoArticulo
          AND pr.VigenteDesdeUtc <= @Ahora
          AND (pr.VigenteHastaUtc IS NULL OR pr.VigenteHastaUtc > @Ahora)
        ORDER BY pr.VigenteDesdeUtc DESC
    ) pr
    ORDER BY p.CodigoArticulo, l.Codigo, l.Moneda;
END;
');
GRANT EXECUTE ON OBJECT::dbo.LeerCatalogoCotizacion TO dayr_catalog_api;
COMMIT;
