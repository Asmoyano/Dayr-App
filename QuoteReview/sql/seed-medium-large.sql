SET XACT_ABORT ON;
SET NOCOUNT ON;
IF DB_NAME() <> N'DAYR_PWA_QUOTE_DEV'
    THROW 51000, 'Select the isolated DAYR_PWA_QUOTE_DEV database.', 1;
BEGIN TRANSACTION;
DECLARE @LockResult int;
EXEC @LockResult = sys.sp_getapplock @Resource = N'DAYR Synthetic Warehouse v1',
    @LockMode = 'Exclusive', @LockOwner = 'Transaction', @LockTimeout = 10000;
IF @LockResult < 0 THROW 51200, 'Could not lock synthetic seed.', 1;

IF EXISTS (SELECT 1 FROM dbo.Lineas WHERE CodigoLinea = 'SIM-LIMPIEZA-V1')
BEGIN
    COMMIT;
    PRINT 'Synthetic dataset v1 already loaded.';
    RETURN;
END;

DECLARE @Familias table (Id int PRIMARY KEY, Nombre nvarchar(80), Estilo nvarchar(80), Precio decimal(10,2));
INSERT @Familias VALUES
    (1,N'Escoba',N'cerda suave',7.50),(2,N'Escoba',N'cerda dura',10.40),
    (3,N'Escobillón',N'para patio',14.90),(4,N'Recogedor',N'con mango',6.90),
    (5,N'Tacho',N'con pedal',32.90),(6,N'Tacho',N'con tapa vaivén',27.40),
    (7,N'Tacho',N'para reciclaje',39.90),(8,N'Balde',N'con asa',12.60),
    (9,N'Trapeador',N'de microfibra',14.90),(10,N'Mopa',N'plana',21.20),
    (11,N'Cepillo',N'para piso',8.70),(12,N'Cepillo',N'para baño',10.30),
    (13,N'Jalador',N'para pisos',15.30),(14,N'Paño',N'multiuso',4.90),
    (15,N'Esponja',N'doble uso',3.50),(16,N'Guante',N'reutilizable',6.20);

DECLARE @N table (Id int PRIMARY KEY);
WITH Digitos AS (SELECT n FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) d(n))
INSERT @N SELECT 1 + a.n + 10*b.n + 100*c.n FROM Digitos a CROSS JOIN Digitos b CROSS JOIN Digitos c;

DECLARE @Almacenes table (Codigo varchar(10) PRIMARY KEY, Nombre nvarchar(150));
INSERT @Almacenes VALUES ('SIM-A',N'Almacén de prueba Centro'), ('SIM-B',N'Almacén de prueba Norte');
INSERT dbo.Almacenes (CodigoAlmacen, Descripcion) SELECT Codigo, Nombre FROM @Almacenes;

INSERT dbo.Pasillos (CodigoAlmacen, CodigoPasillo, Descripcion)
SELECT a.Codigo, CONCAT('P',RIGHT(CONCAT('0',f.Id),2)), CONCAT(f.Nombre,N' ',f.Estilo)
FROM @Almacenes a CROSS JOIN @Familias f;

INSERT dbo.Lineas VALUES ('SIM-LIMPIEZA-V1',N'Catálogo ficticio de limpieza');
INSERT dbo.UnidadesMedida VALUES ('SIM-UND',N'Unidad o presentación de prueba');
INSERT dbo.Familias (CodigoFamilia, Descripcion)
SELECT CONCAT('SIM-F',Id), CONCAT(Nombre,N' ',Estilo) FROM @Familias;

DECLARE @Productos table (Codigo varchar(30) PRIMARY KEY, Familia int, Descripcion nvarchar(250), Precio decimal(19,4));
INSERT @Productos
SELECT CONCAT('SIM-',RIGHT(CONCAT('0',f.Id),2),'-',RIGHT(CONCAT('00',n.Id),3)), f.Id,
       CONCAT(f.Nombre,N' ',f.Estilo,N' · ',m.Modelo,N' · ',c.Color,N' · ',p.Presentacion),
       f.Precio * (1 + 0.16*m.Id) * p.Unidades
FROM @Familias f CROSS JOIN @N n
JOIN (VALUES (0,N'Compacto'),(1,N'Clásico'),(2,N'Reforzado'),(3,N'Grande'),(4,N'Industrial')) m(Id,Modelo)
  ON m.Id = (n.Id-1)/30
JOIN (VALUES (0,N'azul'),(1,N'verde'),(2,N'rojo'),(3,N'gris'),(4,N'negro'),(5,N'blanco')) c(Id,Color)
  ON c.Id = ((n.Id-1)/5)%6
JOIN (VALUES (0,N'unidad',1),(1,N'pack x2',2),(2,N'pack x3',3),(3,N'pack x6',6),(4,N'caja x12',12))
  p(Id,Presentacion,Unidades) ON p.Id = (n.Id-1)%5
WHERE n.Id <= 150;

INSERT dbo.Productos (CodigoArticulo, Descripcion, CodigoUnidad, CodigoLinea, CodigoFamilia)
SELECT Codigo, Descripcion, 'SIM-UND','SIM-LIMPIEZA-V1', CONCAT('SIM-F',Familia) FROM @Productos;

INSERT dbo.Existencias (CodigoArticulo, CodigoAlmacen, StockDisponible, FechaActualizacion)
SELECT p.Codigo, a.Codigo, (CONVERT(int,RIGHT(p.Codigo,3))*13+p.Familia*7+ASCII(RIGHT(a.Codigo,1)))%240,
       SYSUTCDATETIME()
FROM @Productos p CROSS JOIN @Almacenes a;
INSERT dbo.UbicacionesProducto (CodigoArticulo, CodigoAlmacen, CodigoPasillo)
SELECT p.Codigo,a.Codigo,CONCAT('P',RIGHT(CONCAT('0',p.Familia),2))
FROM @Productos p CROSS JOIN @Almacenes a;

IF NOT EXISTS (SELECT 1 FROM dbo.Roles WITH (UPDLOCK,HOLDLOCK) WHERE NombreRol = 'OPERADOR')
    INSERT dbo.Roles (NombreRol,Descripcion) VALUES ('OPERADOR',N'Operador de almacén');
DECLARE @Operador int = (SELECT IdRol FROM dbo.Roles WHERE NombreRol = 'OPERADOR');
INSERT dbo.Usuarios (CodigoUsuario,Nombre,PasswordHash,IdRol,Activo)
SELECT CONCAT(a.Codigo,'-',f.Id),CONCAT(N'Encargado ficticio ',a.Codigo,N' / ',f.Id),
       N'!synthetic-disabled!',@Operador,0
FROM @Almacenes a CROSS JOIN @Familias f;
INSERT dbo.EncargadosPasillo (CodigoAlmacen,IdUsuario,CodigoPasillo)
SELECT a.Codigo,u.IdUsuario,CONCAT('P',RIGHT(CONCAT('0',f.Id),2))
FROM @Almacenes a CROSS JOIN @Familias f
JOIN dbo.Usuarios u ON u.CodigoUsuario = CONCAT(a.Codigo,'-',f.Id);

DECLARE @Listas table (Id int PRIMARY KEY, Codigo varchar(30), Factor decimal(5,2));
INSERT dbo.ListasPrecio (Codigo, Moneda) VALUES ('SIM-MINORISTA','PEN'),('SIM-MAYORISTA','PEN'),('SIM-DISTRIBUIDOR','PEN');
INSERT @Listas
SELECT IdLista,Codigo,CASE Codigo WHEN 'SIM-MINORISTA' THEN 1.00 WHEN 'SIM-MAYORISTA' THEN 0.93 ELSE 0.86 END
FROM dbo.ListasPrecio WHERE Moneda='PEN' AND Codigo IN ('SIM-MINORISTA','SIM-MAYORISTA','SIM-DISTRIBUIDOR');
INSERT dbo.PreciosCatalogo (IdLista,CodigoArticulo,PrecioUnitarioNeto,VigenteDesdeUtc,VersionOrigen)
SELECT l.Id,p.Codigo,p.Precio*l.Factor,'20200101',N'SIMULACION-V1'
FROM @Listas l CROSS JOIN @Productos p;

INSERT dbo.Vendedores (CodigoVendedor,Nombre)
SELECT CONCAT('SIM-V',Id),CONCAT(N'Vendedor ficticio ',Id) FROM @N WHERE Id<=24;
INSERT dbo.AccesoVendedor (Emisor,Sujeto,CodigoVendedor)
SELECT N'urn:dayr:synthetic:untrusted',CONCAT(N'vendedor-',Id),CONCAT('SIM-V',Id) FROM @N WHERE Id<=24;
INSERT dbo.Clientes (CodigoCliente,NombreRazonSocial,TipoPersona)
SELECT CONCAT('SIM-C',Id),CONCAT(CHOOSE((Id-1)%5+1,N'Bazar',N'Ferretería',N'Distribuidora',N'Mercado',N'Servicios'),N' ficticio ',Id),'J'
FROM @N WHERE Id<=480;
INSERT dbo.AccesoClienteVendedor (CodigoVendedor,CodigoCliente,IdLista)
SELECT CONCAT('SIM-V',1+(n.Id-1)/20),CONCAT('SIM-C',n.Id),l.Id
FROM @N n JOIN @Listas l ON l.Codigo = CHOOSE((n.Id-1)%3+1,'SIM-MINORISTA','SIM-MAYORISTA','SIM-DISTRIBUIDOR')
WHERE n.Id<=480;
INSERT dbo.AccesoProductoVendedor (CodigoVendedor,CodigoArticulo)
SELECT CONCAT('SIM-V',n.Id),p.Codigo FROM @N n CROSS JOIN @Productos p
WHERE n.Id<=24 AND (n.Id+p.Familia)%4<>0;

COMMIT;
PRINT 'Synthetic dataset v1 loaded.';
