SET XACT_ABORT ON;
IF DB_NAME() <> N'DAYR_PWA_QUOTE_DEV'
    THROW 51000, 'Select the isolated DAYR_PWA_QUOTE_DEV database.', 1;
BEGIN TRANSACTION;
EXEC(N'
CREATE OR ALTER PROCEDURE dbo.LeerCatalogoCotizacion
    @Emisor nvarchar(200),
    @Sujeto nvarchar(200),
    @CodigoCliente varchar(30) = NULL,
    @DespuesDe varchar(30) = NULL,
    @Limite int = 50,
    @SoloProductos bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    IF @Limite IS NULL OR @Limite NOT BETWEEN 1 AND 101
        THROW 51001, ''Invalid page size.'', 1;

    DECLARE @Vendedor varchar(30);
    SELECT @Vendedor = a.CodigoVendedor
    FROM dbo.AccesoVendedor a
    JOIN dbo.Vendedores v ON v.CodigoVendedor = a.CodigoVendedor AND v.Estado = ''VIGENTE''
    WHERE a.Emisor = @Emisor AND a.Sujeto = @Sujeto
      AND DATALENGTH(a.Emisor) = DATALENGTH(@Emisor)
      AND DATALENGTH(a.Sujeto) = DATALENGTH(@Sujeto);

    IF @Vendedor IS NULL
        THROW 51002, ''Seller access denied.'', 1;

    IF @SoloProductos = 1
    BEGIN
        SELECT TOP (@Limite) p.CodigoArticulo, p.Descripcion, p.CodigoUnidad, p.PermiteDecimal
        FROM dbo.AccesoProductoVendedor a
        JOIN dbo.Productos p ON p.CodigoArticulo = a.CodigoArticulo AND p.Estado = ''VIGENTE''
        WHERE a.CodigoVendedor = @Vendedor
          AND (@DespuesDe IS NULL OR p.CodigoArticulo > @DespuesDe)
        ORDER BY p.CodigoArticulo;
        RETURN;
    END;

    IF @CodigoCliente IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM dbo.AccesoClienteVendedor a
        JOIN dbo.Clientes c ON c.CodigoCliente = a.CodigoCliente AND c.Estado = ''VIGENTE''
        WHERE a.CodigoVendedor = @Vendedor AND a.CodigoCliente = @CodigoCliente)
        THROW 51003, ''Client unavailable.'', 1;

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
