SET NOCOUNT ON;
IF DB_NAME() <> N'DAYR_PWA_QUOTE_DEV'
    THROW 51000, 'Select the isolated DAYR_PWA_QUOTE_DEV database.', 1;
BEGIN TRANSACTION;
BEGIN TRY
    INSERT dbo.UnidadesMedida VALUES ('TST', N'Unidad de prueba');
    INSERT dbo.Productos (CodigoArticulo, Descripcion, CodigoUnidad)
        VALUES ('TEST-A', N'Visible', 'TST'), ('TEST-B', N'Restringido', 'TST'),
               ('TEST-0', N'Sin precio', 'TST');
    INSERT dbo.Vendedores (CodigoVendedor, Nombre) VALUES ('TEST', N'Vendedor de prueba');
    INSERT dbo.Clientes (CodigoCliente, NombreRazonSocial)
        VALUES ('TEST-C', N'Cliente visible'), ('TEST-D', N'Cliente restringido');
    INSERT dbo.AccesoVendedor VALUES (N'test-issuer', N'test-subject', 'TEST');
    INSERT dbo.ListasPrecio (Codigo, Moneda) VALUES ('TEST-L', 'PEN');
    DECLARE @Lista int = CONVERT(int, SCOPE_IDENTITY());
    INSERT dbo.AccesoClienteVendedor VALUES ('TEST', 'TEST-C', @Lista);
    INSERT dbo.AccesoProductoVendedor VALUES ('TEST', 'TEST-A'), ('TEST','TEST-0');
    INSERT dbo.PreciosCatalogo (IdLista, CodigoArticulo, PrecioUnitarioNeto, VigenteDesdeUtc,
        VigenteHastaUtc, VersionOrigen)
    VALUES (@Lista, 'TEST-A', 10.1234, '20200101', NULL, N'v1'),
           (@Lista, 'TEST-A', 999, '99990101', NULL, N'futuro'),
           (@Lista, 'TEST-B', 10, '20200101', NULL, N'v1');

    CREATE TABLE #Clientes (Codigo varchar(30), Nombre nvarchar(200));
    INSERT #Clientes EXEC dbo.LeerCatalogoCotizacion N'test-issuer', N'test-subject';
    IF (SELECT COUNT(*) FROM #Clientes) <> 1 OR NOT EXISTS
        (SELECT 1 FROM #Clientes WHERE Codigo = 'TEST-C')
        THROW 51100, 'Unexpected client scope.', 1;

    CREATE TABLE #Precios (
        Codigo varchar(30), Descripcion nvarchar(250), Unidad varchar(10), PermiteDecimal bit,
        Lista varchar(30), Moneda char(3), Precio decimal(19,4), VersionOrigen nvarchar(100),
        Desde datetime2(3), Hasta datetime2(3), Consultado datetime2(3)
    );
    INSERT #Precios EXEC dbo.LeerCatalogoCotizacion N'test-issuer', N'test-subject', 'TEST-C', NULL, 1;
    IF (SELECT COUNT(*) FROM #Precios) <> 1 OR NOT EXISTS
        (SELECT 1 FROM #Precios WHERE Codigo = 'TEST-A' AND Precio = 10.1234 AND VersionOrigen = N'v1')
        THROW 51101, 'Unexpected product scope, price version or pagination.', 1;
    DELETE FROM #Precios;
    INSERT #Precios EXEC dbo.LeerCatalogoCotizacion N'test-issuer', N'test-subject', 'TEST-D';
    INSERT #Precios EXEC dbo.LeerCatalogoCotizacion N'test-issuer', N'TEST-SUBJECT', 'TEST-C';
    IF EXISTS (SELECT 1 FROM #Precios)
        THROW 51102, 'Unauthorized price disclosure.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.ConfiguracionCotizacion WHERE Id = 1 AND ValidarStock = 0)
        THROW 51103, 'Stock validation should be disabled.', 1;

    BEGIN TRY
        INSERT dbo.AccesoProductoVendedor VALUES ('TEST', 'TEST-MISSING');
        THROW 51104, 'Expected a foreign-key violation.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() <> 547 THROW;
    END CATCH;
    BEGIN TRY
        UPDATE dbo.ConfiguracionCotizacion SET ValidarStock = 1 WHERE Id = 1;
        THROW 51105, 'Expected a stock-flag constraint violation.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() <> 547 THROW;
    END CATCH;

    CREATE USER dayr_catalog_test WITHOUT LOGIN;
    ALTER ROLE dayr_catalog_api ADD MEMBER dayr_catalog_test;
    EXECUTE AS USER = 'dayr_catalog_test';
    DECLARE @DirectSelect int = HAS_PERMS_BY_NAME('dbo.PreciosCatalogo', 'OBJECT', 'SELECT');
    DECLARE @DirectInsert int = HAS_PERMS_BY_NAME('dbo.Movimientos', 'OBJECT', 'INSERT');
    DECLARE @CanReadCatalog int = HAS_PERMS_BY_NAME('dbo.LeerCatalogoCotizacion', 'OBJECT', 'EXECUTE');
    REVERT;
    IF COALESCE(@DirectSelect, 0) <> 0 OR COALESCE(@DirectInsert, 0) <> 0 OR @CanReadCatalog <> 1
        THROW 51106, 'Unexpected API role permissions.', 1;

    ROLLBACK;
    PRINT 'PASS: authorized catalog, isolation, temporal pricing, paging, stock disabled.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    THROW;
END CATCH;
