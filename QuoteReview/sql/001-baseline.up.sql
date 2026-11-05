SET XACT_ABORT ON;
SET NOCOUNT ON;
IF DB_NAME() <> N'DAYR_PWA_QUOTE_DEV'
    THROW 51000, 'Select the isolated DAYR_PWA_QUOTE_DEV database.', 1;
BEGIN TRANSACTION;
-- ============================================
-- TABLA 01: UNIDADES DE MEDIDA
-- ============================================

CREATE TABLE dbo.UnidadesMedida (
    CodigoUnidad VARCHAR(10) NOT NULL,
    Descripcion NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_UnidadesMedida
        PRIMARY KEY (CodigoUnidad)
);

-- ============================================
-- TABLA 02: LINEAS
-- ============================================

CREATE TABLE dbo.Lineas (
    CodigoLinea VARCHAR(20) NOT NULL,
    Descripcion NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_Lineas
        PRIMARY KEY (CodigoLinea)
);

-- ============================================
-- TABLA 03: MARCAS
-- ============================================

CREATE TABLE dbo.Marcas (
    CodigoMarca VARCHAR(20) NOT NULL,
    Descripcion NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_Marcas
        PRIMARY KEY (CodigoMarca)
);

-- ============================================
-- TABLA 04: FAMILIAS
-- ============================================

CREATE TABLE dbo.Familias (
    CodigoFamilia VARCHAR(20) NOT NULL,
    Descripcion NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_Familias
        PRIMARY KEY (CodigoFamilia)
);

-- ============================================
-- TABLA 05: MODELOS
-- ============================================

CREATE TABLE dbo.Modelos (
    CodigoModelo VARCHAR(20) NOT NULL,
    Descripcion NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_Modelos
        PRIMARY KEY (CodigoModelo)
);

-- ============================================
-- TABLA 06: TIPOS DE ARTICULO
-- ============================================

CREATE TABLE dbo.TiposArticulo (
    CodigoTipoArticulo CHAR(1) NOT NULL,
    Descripcion NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_TiposArticulo
        PRIMARY KEY (CodigoTipoArticulo)
);

-- ============================================
-- TABLA 07: PRODUCTOS
-- ============================================

CREATE TABLE dbo.Productos (

    -- Identificación
    CodigoArticulo VARCHAR(30) NOT NULL,
    Descripcion NVARCHAR(250) NOT NULL,
    Descripcion2 NVARCHAR(250) NULL,
    CodigoReferencia VARCHAR(50) NULL,

    -- Unidad de medida
    CodigoUnidad VARCHAR(10) NOT NULL,

    -- Clasificación
    CodigoLinea VARCHAR(20) NULL,
    CodigoMarca VARCHAR(20) NULL,
    CodigoFamilia VARCHAR(20) NULL,
    CodigoModelo VARCHAR(20) NULL,
    CodigoTipoArticulo CHAR(1) NULL,

    -- Control de inventario
    PermiteDecimal BIT NOT NULL
        CONSTRAINT DF_Productos_PermiteDecimal DEFAULT 0,

    ManejaSerie BIT NOT NULL
        CONSTRAINT DF_Productos_ManejaSerie DEFAULT 0,

    ManejaLote BIT NOT NULL
        CONSTRAINT DF_Productos_ManejaLote DEFAULT 0,

    ControlStock BIT NOT NULL
        CONSTRAINT DF_Productos_ControlStock DEFAULT 1,

    -- Estado
    Estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_Productos_Estado DEFAULT 'VIGENTE',

    -- Clave primaria
    CONSTRAINT PK_Productos
        PRIMARY KEY (CodigoArticulo),

    -- Relaciones
    CONSTRAINT FK_Productos_UnidadesMedida
        FOREIGN KEY (CodigoUnidad)
        REFERENCES dbo.UnidadesMedida(CodigoUnidad),

    CONSTRAINT FK_Productos_Lineas
        FOREIGN KEY (CodigoLinea)
        REFERENCES dbo.Lineas(CodigoLinea),

    CONSTRAINT FK_Productos_Marcas
        FOREIGN KEY (CodigoMarca)
        REFERENCES dbo.Marcas(CodigoMarca),

    CONSTRAINT FK_Productos_Familias
        FOREIGN KEY (CodigoFamilia)
        REFERENCES dbo.Familias(CodigoFamilia),

    CONSTRAINT FK_Productos_Modelos
        FOREIGN KEY (CodigoModelo)
        REFERENCES dbo.Modelos(CodigoModelo),

    CONSTRAINT FK_Productos_TiposArticulo
        FOREIGN KEY (CodigoTipoArticulo)
        REFERENCES dbo.TiposArticulo(CodigoTipoArticulo),

    -- Estados permitidos
    CONSTRAINT CK_Productos_Estado
        CHECK (
            Estado IN ('VIGENTE', 'INACTIVO')
        )
);

-- ============================================
-- TABLA 08: ALMACENES
-- ============================================

CREATE TABLE dbo.Almacenes (
    CodigoAlmacen VARCHAR(10) NOT NULL,
    Descripcion NVARCHAR(150) NOT NULL,
    Descripcion2 NVARCHAR(150) NULL,

    -- N = Normal, C = Consignación
    TipoAlmacen CHAR(1) NOT NULL
        CONSTRAINT DF_Almacenes_Tipo
        DEFAULT 'N',

    -- Código de agencia del ERP
    CodigoAgencia VARCHAR(10) NULL,

    CONSTRAINT PK_Almacenes
        PRIMARY KEY (CodigoAlmacen),

    CONSTRAINT CK_Almacenes_Tipo
        CHECK (TipoAlmacen IN ('N', 'C'))
);

-- ============================================
-- TABLA 09: EXISTENCIAS
-- Stock de referencia por producto y almacén
-- ============================================

CREATE TABLE dbo.Existencias (

    CodigoArticulo VARCHAR(30) NOT NULL,
    CodigoAlmacen VARCHAR(10) NOT NULL,

    StockDisponible DECIMAL(18,3) NOT NULL
        CONSTRAINT DF_Existencias_Stock
        DEFAULT 0,

    FechaActualizacion DATETIME2 NULL,

    -- Un registro por artículo y almacén
    CONSTRAINT PK_Existencias
        PRIMARY KEY (
            CodigoArticulo,
            CodigoAlmacen
        ),

    -- Relación con productos
    CONSTRAINT FK_Existencias_Productos
        FOREIGN KEY (CodigoArticulo)
        REFERENCES dbo.Productos(CodigoArticulo),

    -- Relación con almacenes
    CONSTRAINT FK_Existencias_Almacenes
        FOREIGN KEY (CodigoAlmacen)
        REFERENCES dbo.Almacenes(CodigoAlmacen)
);

-- ============================================
-- TABLA 10: ROLES
-- ============================================

CREATE TABLE dbo.Roles (
    IdRol INT IDENTITY(1,1) NOT NULL,
    NombreRol VARCHAR(30) NOT NULL,
    Descripcion NVARCHAR(150) NULL,

    CONSTRAINT PK_Roles
        PRIMARY KEY (IdRol),

    CONSTRAINT UQ_Roles_Nombre
        UNIQUE (NombreRol),

    CONSTRAINT CK_Roles_Nombre
        CHECK (
            NombreRol IN (
                'MASTER',
                'SUPERVISOR',
                'OPERADOR'
            )
        )
);

-- ============================================
-- TABLA 11: USUARIOS
-- ============================================

CREATE TABLE dbo.Usuarios (
    IdUsuario INT IDENTITY(1,1) NOT NULL,

    -- Identificación
    CodigoUsuario VARCHAR(30) NOT NULL,
    Nombre NVARCHAR(150) NOT NULL,

    -- Correo opcional, pendiente de confirmar
    Correo NVARCHAR(150) NULL,

    -- Credenciales propias de la PWA
    PasswordHash NVARCHAR(255) NOT NULL,

    -- Rol del usuario
    IdRol INT NOT NULL,

    -- Estado y trazabilidad
    Activo BIT NOT NULL
        CONSTRAINT DF_Usuarios_Activo DEFAULT 1,

    FechaCreacion DATETIME2 NOT NULL
        CONSTRAINT DF_Usuarios_FechaCreacion
        DEFAULT SYSDATETIME(),

    FechaActualizacion DATETIME2 NULL,

    CONSTRAINT PK_Usuarios
        PRIMARY KEY (IdUsuario),

    CONSTRAINT UQ_Usuarios_Codigo
        UNIQUE (CodigoUsuario),

    CONSTRAINT FK_Usuarios_Roles
        FOREIGN KEY (IdRol)
        REFERENCES dbo.Roles(IdRol)
);

-- ============================================
-- TABLA 12: SESIONES DE CONTEO
-- ============================================

CREATE TABLE dbo.SesionesConteo (
    IdSesion INT IDENTITY(1,1) NOT NULL,
    CodigoAlmacen VARCHAR(10) NOT NULL,
    IdUsuarioResponsable INT NOT NULL,

    FechaInicio DATETIME2 NOT NULL
        DEFAULT SYSDATETIME(),
    FechaFin DATETIME2 NULL,

    Estado VARCHAR(20) NOT NULL
        DEFAULT 'ABIERTA',

    Observaciones NVARCHAR(500) NULL,

    CONSTRAINT PK_SesionesConteo
        PRIMARY KEY (IdSesion),

    CONSTRAINT FK_Sesiones_Almacenes
        FOREIGN KEY (CodigoAlmacen)
        REFERENCES dbo.Almacenes(CodigoAlmacen),

    CONSTRAINT FK_Sesiones_Usuarios
        FOREIGN KEY (IdUsuarioResponsable)
        REFERENCES dbo.Usuarios(IdUsuario),

    CONSTRAINT CK_Sesiones_Estado
        CHECK (
            Estado IN (
                'ABIERTA',
                'EN_PROCESO',
                'FINALIZADA',
                'CANCELADA'
            )
        ),

    CONSTRAINT CK_Sesiones_Fechas
        CHECK (
            FechaFin IS NULL
            OR FechaFin >= FechaInicio
        )
);

-- ============================================
-- TABLA 13: ASIGNACIONES DE CONTEO
-- ============================================

CREATE TABLE dbo.AsignacionesConteo (
    IdAsignacion INT IDENTITY(1,1) NOT NULL,
    IdSesion INT NOT NULL,
    CodigoArticulo VARCHAR(30) NOT NULL,

    -- Existencia de referencia al preparar el conteo
    StockReferencia DECIMAL(18,3) NOT NULL,

    -- Usuario encargado (opcional)
    IdUsuarioAsignado INT NULL,

    Estado VARCHAR(20) NOT NULL
        DEFAULT 'PENDIENTE',

    CONSTRAINT PK_AsignacionesConteo
        PRIMARY KEY (IdAsignacion),

    CONSTRAINT FK_Asignaciones_Sesiones
        FOREIGN KEY (IdSesion)
        REFERENCES dbo.SesionesConteo(IdSesion),

    CONSTRAINT FK_Asignaciones_Productos
        FOREIGN KEY (CodigoArticulo)
        REFERENCES dbo.Productos(CodigoArticulo),

    CONSTRAINT FK_Asignaciones_Usuarios
        FOREIGN KEY (IdUsuarioAsignado)
        REFERENCES dbo.Usuarios(IdUsuario),

    -- Un artículo por sesión
    CONSTRAINT UQ_Asignaciones_SesionArticulo
        UNIQUE (IdSesion, CodigoArticulo),

    CONSTRAINT CK_Asignaciones_Estado
        CHECK (
            Estado IN (
                'PENDIENTE',
                'EN_PROCESO',
                'CONTADO',
                'REVISADO'
            )
        )
);

-- ============================================
-- TABLA 14: REGISTROS DE CONTEO
-- ============================================

CREATE TABLE dbo.RegistrosConteo (
    IdRegistro INT IDENTITY(1,1) NOT NULL,
    IdAsignacion INT NOT NULL,
    IdUsuario INT NOT NULL,

    -- 1 = primer conteo, 2 = reconteo, etc.
    NumeroConteo INT NOT NULL,

    CantidadContada DECIMAL(18,3) NOT NULL,

    FechaRegistro DATETIME2 NOT NULL
        DEFAULT SYSDATETIME(),

    Observaciones NVARCHAR(500) NULL,

    CONSTRAINT PK_RegistrosConteo
        PRIMARY KEY (IdRegistro),

    CONSTRAINT FK_Registros_Asignaciones
        FOREIGN KEY (IdAsignacion)
        REFERENCES dbo.AsignacionesConteo(IdAsignacion),

    CONSTRAINT FK_Registros_Usuarios
        FOREIGN KEY (IdUsuario)
        REFERENCES dbo.Usuarios(IdUsuario),

    CONSTRAINT UQ_Registros_NumeroConteo
        UNIQUE (IdAsignacion, NumeroConteo),

    CONSTRAINT UQ_Registros_AsignacionRegistro
        UNIQUE (IdAsignacion, IdRegistro),

    CONSTRAINT CK_Registros_NumeroConteo
        CHECK (NumeroConteo >= 1),

    CONSTRAINT CK_Registros_Cantidad
        CHECK (CantidadContada >= 0)
);

-- ============================================
-- TABLA 15: CONCILIACIONES
-- ============================================

CREATE TABLE dbo.Conciliaciones (
    IdConciliacion INT IDENTITY(1,1) NOT NULL,
    IdAsignacion INT NOT NULL,

    -- Registro elegido como resultado definitivo
    IdRegistroFinal INT NULL,

    Estado VARCHAR(20) NOT NULL
        DEFAULT 'PENDIENTE',

    IdUsuarioRevisor INT NULL,
    FechaRevision DATETIME2 NULL,

    Observaciones NVARCHAR(500) NULL,

    CONSTRAINT PK_Conciliaciones
        PRIMARY KEY (IdConciliacion),

    CONSTRAINT UQ_Conciliaciones_Asignacion
        UNIQUE (IdAsignacion),

    CONSTRAINT FK_Conciliaciones_Asignaciones
        FOREIGN KEY (IdAsignacion)
        REFERENCES dbo.AsignacionesConteo(IdAsignacion),

    CONSTRAINT FK_Conciliaciones_Registros
        FOREIGN KEY (IdAsignacion, IdRegistroFinal)
        REFERENCES dbo.RegistrosConteo(
            IdAsignacion,
            IdRegistro
        ),

    CONSTRAINT FK_Conciliaciones_Usuarios
        FOREIGN KEY (IdUsuarioRevisor)
        REFERENCES dbo.Usuarios(IdUsuario),

    CONSTRAINT CK_Conciliaciones_Estado
        CHECK (
            Estado IN (
                'PENDIENTE',
                'EN_REVISION',
                'APROBADA',
                'RECHAZADA'
            )
        )
);

-- ============================================
-- TABLA 16: CLIENTES
-- ============================================

CREATE TABLE dbo.Clientes (
    CodigoCliente VARCHAR(30) NOT NULL,
    NombreRazonSocial NVARCHAR(200) NOT NULL,

    -- N = Natural, J = Jurídica
    TipoPersona CHAR(1) NULL,

    TipoDocumento VARCHAR(10) NULL,
    NumeroDocumento VARCHAR(20) NULL,

    Estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_Clientes_Estado
        DEFAULT 'VIGENTE',

    CONSTRAINT PK_Clientes
        PRIMARY KEY (CodigoCliente),

    CONSTRAINT CK_Clientes_TipoPersona
        CHECK (
            TipoPersona IS NULL
            OR TipoPersona IN ('N', 'J')
        ),

    CONSTRAINT CK_Clientes_Estado
        CHECK (
            Estado IN ('VIGENTE', 'INACTIVO')
        )
);

-- ============================================
-- TABLA 17: PROVEEDORES
-- ============================================

CREATE TABLE dbo.Proveedores (
    CodigoProveedor VARCHAR(30) NOT NULL,
    NombreRazonSocial NVARCHAR(200) NOT NULL,

    -- N = Natural, J = Jurídica
    TipoPersona CHAR(1) NULL,

    NumeroDocumento VARCHAR(20) NULL,

    Estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_Proveedores_Estado
        DEFAULT 'VIGENTE',

    CONSTRAINT PK_Proveedores
        PRIMARY KEY (CodigoProveedor),

    CONSTRAINT CK_Proveedores_TipoPersona
        CHECK (
            TipoPersona IS NULL
            OR TipoPersona IN ('N', 'J')
        ),

    CONSTRAINT CK_Proveedores_Estado
        CHECK (
            Estado IN ('VIGENTE', 'INACTIVO')
        )
);

-- ============================================
-- TABLA 18: VENDEDORES
-- ============================================

CREATE TABLE dbo.Vendedores (
    CodigoVendedor VARCHAR(30) NOT NULL,
    Nombre NVARCHAR(150) NOT NULL,

    Estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_Vendedores_Estado
        DEFAULT 'VIGENTE',

    CONSTRAINT PK_Vendedores
        PRIMARY KEY (CodigoVendedor),

    CONSTRAINT CK_Vendedores_Estado
        CHECK (
            Estado IN ('VIGENTE', 'INACTIVO')
        )
);

-- ============================================
-- TABLA 19: TIPOS DE MOVIMIENTO
-- ============================================

CREATE TABLE dbo.TiposMovimiento (
    TipoMovimiento CHAR(1) NOT NULL,
    CodigoMovimiento VARCHAR(10) NOT NULL,
    Descripcion NVARCHAR(150) NOT NULL,

    CONSTRAINT PK_TiposMovimiento
        PRIMARY KEY (
            TipoMovimiento,
            CodigoMovimiento
        ),

    CONSTRAINT CK_TiposMovimiento_Tipo
        CHECK (TipoMovimiento IN ('E', 'S'))
);

-- ============================================
-- TABLA 20: MOVIMIENTOS
-- ============================================

CREATE TABLE dbo.Movimientos (
    IdMovimiento INT IDENTITY(1,1) NOT NULL,

    -- Almacén donde se registra el movimiento
    CodigoAlmacen VARCHAR(10) NOT NULL,

    -- E = Entrada, S = Salida
    TipoMovimiento CHAR(1) NOT NULL,
    CodigoMovimiento VARCHAR(10) NOT NULL,

    -- Documento del ERP
    NumeroDocumento VARCHAR(30) NOT NULL,
    FechaDocumento DATE NOT NULL,

    -- Participantes opcionales
    CodigoProveedor VARCHAR(30) NULL,
    CodigoCliente VARCHAR(30) NULL,

    -- Almacén relacionado, si corresponde
    CodigoAlmacenReferencia VARCHAR(10) NULL,

    -- Descripción u observación
    Glosa NVARCHAR(500) NULL,

    CONSTRAINT PK_Movimientos
        PRIMARY KEY (IdMovimiento),

    CONSTRAINT FK_Movimientos_Almacenes
        FOREIGN KEY (CodigoAlmacen)
        REFERENCES dbo.Almacenes(CodigoAlmacen),

    CONSTRAINT FK_Movimientos_TiposMovimiento
        FOREIGN KEY (TipoMovimiento, CodigoMovimiento)
        REFERENCES dbo.TiposMovimiento(
            TipoMovimiento,
            CodigoMovimiento
        ),

    CONSTRAINT FK_Movimientos_Proveedores
        FOREIGN KEY (CodigoProveedor)
        REFERENCES dbo.Proveedores(CodigoProveedor),

    CONSTRAINT FK_Movimientos_Clientes
        FOREIGN KEY (CodigoCliente)
        REFERENCES dbo.Clientes(CodigoCliente),

    CONSTRAINT FK_Movimientos_AlmacenReferencia
        FOREIGN KEY (CodigoAlmacenReferencia)
        REFERENCES dbo.Almacenes(CodigoAlmacen)
);

-- ============================================
-- TABLA 21: DETALLE DE MOVIMIENTOS
-- ============================================

CREATE TABLE dbo.MovimientoDetalles (
    IdDetalle INT IDENTITY(1,1) NOT NULL,
    IdMovimiento INT NOT NULL,
    CodigoArticulo VARCHAR(30) NOT NULL,

    Cantidad DECIMAL(18,3) NOT NULL,

    CONSTRAINT PK_MovimientoDetalles
        PRIMARY KEY (IdDetalle),

    CONSTRAINT FK_MovimientoDetalles_Movimientos
        FOREIGN KEY (IdMovimiento)
        REFERENCES dbo.Movimientos(IdMovimiento),

    CONSTRAINT FK_MovimientoDetalles_Productos
        FOREIGN KEY (CodigoArticulo)
        REFERENCES dbo.Productos(CodigoArticulo),

    CONSTRAINT CK_MovimientoDetalles_Cantidad
        CHECK (Cantidad > 0)
);

-- ============================================
-- TABLA 22: GUIAS
-- ============================================

CREATE TABLE dbo.Guias (
    IdGuia INT IDENTITY(1,1) NOT NULL,

    -- Almacén desde donde se emite
    CodigoAlmacen VARCHAR(10) NOT NULL,

    -- Identificación de la guía
    Serie VARCHAR(10) NOT NULL,
    NumeroDocumento VARCHAR(30) NOT NULL,
    FechaDocumento DATE NOT NULL,

    -- Tipo de guía mostrado en el ERP
    TipoGuia VARCHAR(10) NULL,

    -- Destinatario o proveedor, según corresponda
    CodigoCliente VARCHAR(30) NULL,
    CodigoProveedor VARCHAR(30) NULL,

    -- Vendedor, si corresponde
    CodigoVendedor VARCHAR(30) NULL,

    -- Motivo y observaciones
    MotivoTraslado NVARCHAR(150) NULL,
    Glosa NVARCHAR(500) NULL,

    -- Movimiento asociado, si existe
    IdMovimiento INT NULL,

    CONSTRAINT PK_Guias
        PRIMARY KEY (IdGuia),

    CONSTRAINT UQ_Guias_AlmacenSerieNumero
        UNIQUE (
            CodigoAlmacen,
            Serie,
            NumeroDocumento
        ),

    CONSTRAINT FK_Guias_Almacenes
        FOREIGN KEY (CodigoAlmacen)
        REFERENCES dbo.Almacenes(CodigoAlmacen),

    CONSTRAINT FK_Guias_Clientes
        FOREIGN KEY (CodigoCliente)
        REFERENCES dbo.Clientes(CodigoCliente),

    CONSTRAINT FK_Guias_Proveedores
        FOREIGN KEY (CodigoProveedor)
        REFERENCES dbo.Proveedores(CodigoProveedor),

    CONSTRAINT FK_Guias_Vendedores
        FOREIGN KEY (CodigoVendedor)
        REFERENCES dbo.Vendedores(CodigoVendedor),

    CONSTRAINT FK_Guias_Movimientos
        FOREIGN KEY (IdMovimiento)
        REFERENCES dbo.Movimientos(IdMovimiento)
);

-- ============================================
-- TABLA 23: DETALLE DE GUIAS
-- ============================================

CREATE TABLE dbo.GuiaDetalles (
    IdGuiaDetalle INT IDENTITY(1,1) NOT NULL,
    IdGuia INT NOT NULL,
    CodigoArticulo VARCHAR(30) NOT NULL,

    -- Cantidad indicada en la guía
    Cantidad DECIMAL(18,3) NOT NULL,

    CONSTRAINT PK_GuiaDetalles
        PRIMARY KEY (IdGuiaDetalle),

    CONSTRAINT FK_GuiaDetalles_Guias
        FOREIGN KEY (IdGuia)
        REFERENCES dbo.Guias(IdGuia),

    CONSTRAINT FK_GuiaDetalles_Productos
        FOREIGN KEY (CodigoArticulo)
        REFERENCES dbo.Productos(CodigoArticulo),

    CONSTRAINT CK_GuiaDetalles_Cantidad
        CHECK (Cantidad > 0)
);

COMMIT;
