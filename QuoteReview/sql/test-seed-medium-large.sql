SET NOCOUNT ON;
IF DB_NAME() <> N'DAYR_PWA_QUOTE_DEV'
    THROW 51000, 'Select the isolated DAYR_PWA_QUOTE_DEV database.', 1;

DECLARE @Productos int = (SELECT COUNT(*) FROM dbo.Productos WHERE CodigoLinea='SIM-LIMPIEZA-V1');
DECLARE @Ubicaciones int = (
    SELECT COUNT(*) FROM dbo.UbicacionesProducto u JOIN dbo.Productos p ON p.CodigoArticulo=u.CodigoArticulo
    WHERE p.CodigoLinea='SIM-LIMPIEZA-V1');
DECLARE @Pasillos int = (SELECT COUNT(*) FROM dbo.Pasillos WHERE CodigoAlmacen IN ('SIM-A','SIM-B'));
DECLARE @Encargados int = (SELECT COUNT(*) FROM dbo.EncargadosPasillo WHERE CodigoAlmacen IN ('SIM-A','SIM-B'));
DECLARE @Clientes int = (SELECT COUNT(*) FROM dbo.Clientes WHERE CodigoCliente LIKE 'SIM-C%');
DECLARE @Vendedores int = (SELECT COUNT(*) FROM dbo.Vendedores WHERE CodigoVendedor LIKE 'SIM-V%');
DECLARE @Precios int = (SELECT COUNT(*) FROM dbo.PreciosCatalogo WHERE VersionOrigen=N'SIMULACION-V1');

IF @Productos <> 2400 OR @Ubicaciones <> 4800 OR @Pasillos <> 32 OR @Encargados <> 32
   OR @Clientes <> 480 OR @Vendedores <> 24 OR @Precios <> 7200
    THROW 51201, 'Unexpected synthetic dataset counts.', 1;

IF EXISTS (
    SELECT 1 FROM dbo.Pasillos p
    WHERE p.CodigoAlmacen IN ('SIM-A','SIM-B') AND (
        (SELECT COUNT(*) FROM dbo.UbicacionesProducto u WHERE
         u.CodigoAlmacen=p.CodigoAlmacen AND u.CodigoPasillo=p.CodigoPasillo) <> 150
        OR NOT EXISTS (SELECT 1 FROM dbo.EncargadosPasillo e WHERE
         e.CodigoAlmacen=p.CodigoAlmacen AND e.CodigoPasillo=p.CodigoPasillo)))
    THROW 51202, 'Unexpected synthetic aisle coverage.', 1;

CREATE TABLE #Clientes (Codigo varchar(30), Nombre nvarchar(200));
INSERT #Clientes EXEC dbo.LeerCatalogoCotizacion N'urn:dayr:synthetic:untrusted', N'vendedor-1';
IF (SELECT COUNT(*) FROM #Clientes) <> 20
    THROW 51203, 'Unexpected synthetic seller portfolio.', 1;

SELECT @Productos AS Productos, @Ubicaciones AS Ubicaciones, @Pasillos AS Pasillos,
       @Encargados AS Encargados, @Clientes AS Clientes, @Vendedores AS Vendedores,
       @Precios AS Precios;
PRINT 'PASS: synthetic counts, aisle coverage and seller portfolio.';
