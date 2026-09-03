# 03. Módulos Relacionados de e-SOFTCOM SQL v21.53

## Módulos Identificados
* **Módulo Archivos:** Fuente de información donde se obtendrán las tablas maestras, las tablas que se tocarán son las siguientes:
  * Artículos
  * Clientes
  * Vendedores
  * Transportistas
  * Proveedores
  * Códigos almacén
  * Códigos movimiento
  * Ingreso descuentos
  * Línea productos
  * Forma de venta
  * Zonas de venta
  * Cuentas existencia
  * Supervisor (por confirmar)
  * Requisición compra (por confirmar)
* **Módulo Pedidos:** Gestión de pedidos hechos por los clientes. Acciones que puede realizar este módulo:
  * Standard sin stock
  * Descuento automático
  * Descuento automático sin stock
  * Aprobación pedidos
  * Liquidación de pedidos
  * Reporte de pedidos
  * Reporte de pedidos resumen
  * Pedidos pendientes despacho
  * Factura diferida parcial contra pedido
  * Descuento automático libre
* **Módulo Facturación:** Se tocará únicamente la parte de cotizaciones.
* **Módulo Créditos y Cobranzas:** Se tocará únicamente la función para consulta crediticia por cliente.
* **Módulo Almacén:** Gestión de actividades realizadas por almacén. Se registran entradas, salidas, guías, kits, y se pueden crear reportes.

## Estado de Integración
* **Base de Datos:** SQL Server 2014.
* **Mecanismo Actual:** Procesamiento de datos dependiente de archivos Excel y digitación manual.