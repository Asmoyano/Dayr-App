# 02. Alcance Inicial del Proyecto

## Dentro del Alcance (In-Scope)
* **PWA Campo:** Registro manual de pedidos, toma de pedidos sin red, consulta offline de catálogo de productos e historial local.
* **PWA Almacén:** Registro de entradas/salidas, verificación manual de inventario y sincronización de stock.
* **Middleware API (.NET Core):** Endpoints REST para autenticación, gestión de pedidos e inventario, y capa de persistencia local (IndexedDB/CacheStorage).
* **Entorno de Mocking:** Abstracción total mediante interfaces para trabajar sin acceso directo a la BD corporativa en fases iniciales.

## Fuera del Alcance (Out-of-Scope)
* Modificación directa del código fuente o procedimientos almacenados core del sistema e-SOFTCOM SQL.
* Procesamiento automatizado de facturación electrónica dentro de la PWA (delegado al ERP legacy).