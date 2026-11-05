# DAYR PWA · revisión de catálogos y cotizaciones

## Ejecución aislada

Origen: bd_pwa_venta_almacen.sql del 5 de noviembre, SHA-256
F3432381A9798E8FF1A9792856F25A34F62FEEE21AAA97FC1AD3D6884E47F0D8.

1. En una instancia SQL Server exclusiva de desarrollo, aprovisionar una base nueva vacía llamada DAYR_PWA_QUOTE_DEV. Confirmar instancia y base desde la conexión administrativa. El nombre exigido por los scripts es una protección adicional.
2. Con sqlcmd, utilizar `-S <instancia-dev> -E -d DAYR_PWA_QUOTE_DEV -b -f 65001 -i <archivo>`. Ejecutar primero `sql/001-baseline.up.sql`, luego `sql/002-catalog.up.sql` y después `sql/test-catalog.sql`. Usar una identidad administrativa de desarrollo para estos pasos. La cuenta web se asigna por separado al rol dayr_catalog_api y recibe solo EXECUTE sobre la consulta. No asignar db_datareader ni db_datawriter.
3. Cada versión se aplica una vez y en orden. Las migraciones usan una transacción y XACT_ABORT. Para una instalación preexistente, comparar primero su esquema con 001 y decidir con Sistemas si corresponde registrar la base como equivalente en la herramienta de migraciones elegida. No reaplicar 001 a una base con tablas existentes.
4. Los down se reservan para una base vacía de ensayo y se ejecutan en orden 002, 001. Rechazan el retiro si encuentran filas de negocio, con bloqueos durante la comprobación. El único registro retirado por 002 es la configuración inicial con stock deshabilitado. Para bases con datos, retirar acceso al servicio y diseñar una migración correctiva hacia adelante.
5. `dotnet run --project QuoteReview.csproj` compila el controlador y corre nueve comprobaciones del cálculo.

## Auditoría del esquema recibido

| Área | Observación y decisión |
|---|---|
| Motor | T-SQL de SQL Server. Usa GO como separador de cliente, IDENTITY, BIT, DATETIME2 y SYSDATETIME. La prueba original de DB_ID apuntaba a tesis_inventario antes de crear otra base. 001 elimina creación y cambio de contexto, conserva las 23 tablas y las aplica en una transacción. |
| Maestro de artículos | Productos referencia UnidadesMedida, Lineas, Marcas, Familias, Modelos y TiposArticulo. Las clasificaciones son opcionales y unidad es obligatoria. Los códigos naturales son apropiados si son estables y globales en el ERP. Si se repiten entre empresas, exigir correspondencia explícita por empresa antes de importar. No se presume jerarquía entre línea, familia y modelo. |
| Existencias | Almacenes y Existencias dan una fila por artículo y almacén. FechaActualizacion admite nulo y StockDisponible admite negativos. Sistemas debe aclarar si representan faltantes legítimos y si la fecha corresponde a captura o ERP. ControlStock del producto es un atributo importado, separado del flag de cotización. |
| Identidad | Roles admite tres valores y Usuarios posee un solo rol y una columna PasswordHash obligatoria. Se conserva como estructura heredada. Para cotizar se usa identidad externa validada y asignación explícita emisor/sujeto a vendedor activo. No se incluyen usuarios ni valores de hashes de credenciales. |
| Conteos | SesionesConteo → AsignacionesConteo → RegistrosConteo; Conciliaciones apunta por FK compuesta al registro de la misma asignación. Los CHECK validan fechas, estados, cantidad y número de recuento, pero no las transiciones, el revisor obligatorio al aprobar ni que la sesión esté abierta al contar. El módulo de cotización carece de permisos sobre esta cadena. |
| Terceros | Clientes, Proveedores y Vendedores tienen códigos independientes. Tipo y número de documento en Clientes pueden faltar o quedar desparejados. Confirmar duplicados, normalización y reglas por tipo antes de imponer unicidad o exponer documentos personales. El catálogo solo entrega código y razón social. |
| Documentos | TiposMovimiento tiene PK compuesta, referenciada por Movimientos. Las líneas apuntan a su cabecera y producto, con cantidades positivas. Guias usa unicidad almacén/serie/número y FK opcional a movimiento. El DDL no vincula almacenes entre ambos ni define una clave externa de idempotencia para movimientos. Validar claves y correspondencia en staging antes de replicar. |
| Índices | El original declara PK y UNIQUE, sin índices explícitos de soporte de FK. 002 agrega los índices de las nuevas FK que carecen de prefijo útil. Para almacén, medir primero consultas por almacén/artículo, fecha/documento y sesiones abiertas. |
| Auditoría | Las fechas heredadas usan hora del servidor y faltan actor/origen en varios catálogos. Los precios nuevos guardan versión de origen, intervalo y registro en UTC. La auditoría de importación y cambios de autorización corresponde a Sistemas y queda por implementar. |

El original carece de tablas de cotizaciones. La cabecera y las partidas de campo pertenecen al borrador local. Las tablas heredadas de guías y movimientos conservan su representación del ERP y quedan fuera del servicio de cotización.

## Catálogos y backend

- Identidad validada → AccesoVendedor → Vendedores. AccesoClienteVendedor autoriza combinaciones de vendedor, cliente y lista. AccesoProductoVendedor autoriza artículos. ListasPrecio define código y moneda. PreciosCatalogo tiene FK a lista y artículo, precio neto DECIMAL(19,4) y vigencia [desde, hasta). Dentro de una lista y artículo, gana la vigencia activa de inicio más reciente. Confirmar con Sistemas si se aceptarán superposiciones o se rechazarán durante la importación. El catálogo devuelve las listas autorizadas, sin elegir una automáticamente.
- Incorporar QuoteCatalogController.cs al proyecto Backend. Configurar autenticación con emisor, firma, audiencia y vencimiento validados, preservar los claims iss/sub, y registrar la política DayrQuoteCatalog para usuarios autenticados del módulo. Inyectar un DbDataSource SQL Server (por ejemplo Microsoft.Data.SqlClient) usando una conexión de desarrollo configurada fuera del repositorio. La app debe obtener el emisor y el sujeto del token validado. La cuenta de base es exclusiva de la API y no se distribuye a la PWA.
- GET /v1/quote-catalog/clients devuelve clientes activos autorizados. GET /v1/quote-catalog/clients/{clientCode}/prices devuelve artículos activos con precio autorizado para ese cliente. Cada producto puede tener varias listas. El parámetro after usa el último código de cliente o artículo y limit cuenta clientes o productos. Una identidad sin asignación obtiene páginas vacías. El precio viaja como cadena decimal de cuatro posiciones para preservar precisión.
- Antes de habilitar esta ruta en campo, acordar expiración del catálogo local, aislamiento por cuenta en dispositivos compartidos, revocación al reconectar, borrado de caché al cerrar sesión y manejo de datos obsoletos. Evitar almacenar las respuestas autenticadas en el service worker. Si se autoriza una descarga de catálogo, guardar solo lo necesario en IndexedDB con versión y caducidad. La paginación actual consulta datos vigentes en cada petición, por lo que una publicación simultánea puede cambiar páginas. Para una descarga consistente, publicar instantáneas identificadas por versión.
- El controlador y el cálculo compilan como paquete separado. El backend operativo que se pudo leer apunta a net10.0 y su ruta de inventario actual sirve datos sintéticos en Development. Registrar el proveedor y la política en ese backend es un paso de integración pendiente.

## Cotización local y PDF

- QuoteCalculator.cs sigue el orden de quotes.service.ts: cantidad por precio neto, descuento porcentual por partida, redondeo a dos decimales por partida, suma del subtotal, impuesto global y total. El 18 % está en la configuración actual de la PWA. La tasa es explícita en el servicio. Usar cantidades con hasta tres decimales según unidad y confirmar el máximo comercial, la escala de descuentos, la moneda y las exoneraciones antes de validar en la UI. Para partidas fraccionarias, el descuento mostrado como bruto redondeado menos subtotal puede resultar negativo por un céntimo debido al orden heredado. La prueba lo documenta. Se requiere decisión comercial para cambiar el criterio coordinadamente en frontend y backend.
- localQuoteDrafts.ts implementa almacenamiento IndexedDB local por cuenta e ID y revisión optimista por transacción. Integrar en el flujo de Ventas en lugar del almacenamiento mock en memoria. Generar UUID en el dispositivo y conservar instantánea de descripción, cliente, cantidades, precio, lista/versión y tasa junto al borrador. Usar aritmética decimal en el navegador al adoptar este contrato y compartir vectores de prueba con .NET. El alcance por cuenta en IndexedDB es una separación lógica en la app, por lo que no sustituye las políticas de seguridad de dispositivo compartido.
- IQuotePdfRenderer define entradas separadas con y sin precios. El frontend ya contiene un exportador HTML de ejemplo en quoteExport.ts que se puede usar para revisar los dos flujos offline. La versión sin precios debe excluir importes, descuentos e impuestos también en metadatos. Los formatos corporativos y la adaptación del exportador a borradores persistidos quedan pendientes.

## Integración futura supervisada por Sistemas

| Entidad | Autoridad | Flujo previsto |
|---|---|---|
| Clientes, productos, precios, listas y existencias | ERP | Lectura hacia staging DAYR. Existencias de referencia fuera de las consultas de cotización. |
| Identidad y permisos | Proveedor de identidad y Sistemas | Asignaciones controladas, historial de cambios y retiro de permisos. |
| Cotización de campo | Dispositivo del vendedor | Borrador y PDF offline. El borrador se identifica localmente. |
| Órdenes, guías y ajustes de inventario | ERP | Cualquier alta futura requiere autorización y contrato específico por operación. |

Un importador futuro debe recibir lote, origen, ID de evento y versión, validar en staging claves, moneda, vigencias, referencias y conteos y reconciliar antes de publicar. Inbox con unicidad (origen, ID de evento), hash y estado. Una repetición con otro hash se envía a cuarentena. Aplicación y confirmación de inbox comparten transacción. Sistemas aprueba diferencias antes de publicar un lote y conserva correlación, actor técnico y timestamps UTC.

Para cualquier flujo saliente que se apruebe, grabar cambio y outbox en una transacción, reclamar trabajo con concesión temporal, reintentar con la misma clave idempotente, guardar confirmación ERP, conciliar con el destino y alertar al agotar intentos. Usar cuentas separadas por dirección y operación, lista explícita de entidades y auditoría con acceso restringido. ValidarStock permanece en 0 y un CHECK rechaza su activación en esta versión. La conectividad ERP, los workers, la sincronización de borradores y las escrituras de órdenes y stock quedan fuera del paquete.

## Revisión de secretos y límites

El SQL fuente contiene DDL y una columna PasswordHash, sin valores de credenciales ni cadenas de conexión. La revisión local de código buscó patrones de secretos sin imprimir sus valores. La auditoría de todo el historial Git y de los archivos de configuración fuera del alcance de lectura sigue pendiente. El repositorio abierto es Sala DAYR. La entrega se versiona en una copia local aislada de Dayr-App basada en 8bfc1c4a4971e9bffe95acb11a0147f2c93e1ddf. La copia de trabajo operativa tiene cambios previos en Frontend y artefactos generados que se conservaron en su ubicación. El frontend PWA separado estaba limpio en 467f2cc310c3864720fdd99b4bc150daa08f34f5.

## Evidencia de pruebas

- SQL Server LocalDB 17, instancia privada MSSQLLocalDB y base nueva DAYR_PWA_QUOTE_DEV. Migraciones 001 y 002 y test-catalog.sql exitosos. Resultado de verificación: 29 tablas, 0 productos después de revertir los datos ficticios y ValidarStock = 0. Los scripts down se entregan para revisión y no se ejecutaron.
- .NET 10: nueve comprobaciones de cálculo y pruebas de los dos HTML de demostración, incluido escape de texto y omisión de importes. Ejecutar desde QuoteReview con `dotnet run -- --demo` para escribir ambos archivos HTML, imprimibles a PDF sin conexión y sin recursos externos. El cálculo, los contratos y la vista de demostración están en Backend/Services/Quotations.
- TypeScript: comprobación estricta del módulo IndexedDB. Pendiente validación en navegador del flujo de Ventas, persistencia tras recarga y concurrencia entre pestañas.

La compilación del proyecto Backend.csproj de esta rama terminó con 0 errores y 0 advertencias. La búsqueda de firmas de credenciales en los archivos de texto versionados revisados del HEAD base de Dayr-App tampoco produjo coincidencias.
