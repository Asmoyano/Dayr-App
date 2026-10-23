# Sistema DAYR PWA - Diseño preliminar de funcionamiento offline

**23/10/2026 | Versión 0.1 | PROPUESTA pendiente de aprobación funcional y de seguridad**

## 1. Alcance, referencias y método

Análisis estático, sin implementar cambios ni ejecutar nuevas pruebas funcionales. Frontend oficial: Asmoyano/dayr-inventory-hub, commit `e49c3e4847b655dbd5e5588fa3949ff71562eaac`; se consultó main remoto el 23/10/2026 y coincide. Se inspeccionó la copia de auditoría identificada, no el frontend histórico como sustituto. Backend original: `C:/Users/mayon/Desktop/dayr/Dayr_App/Backend/Backend.slnx`, commit local `3fbbc57b7603b58e277fe98d9217b6fc1313bc70`, rama codex/backend-initial-conditioning. Los cambios locales ajenos se conservan.

La carpeta Documentacion de Dayr-App ya concentra alcance, entrevistas e integración; este documento y su [matriz de pruebas](Matriz_Pruebas_Offline.md) son la referencia transversal de arquitectura. Relacionados: [integraciones](08_Integraciones.md), [diseño de alertas](Diseno_Preliminar_Alertas_Stock.md), [backend actual](../Backend/README.md). No se duplica el diseño en la copia temporal del frontend ni se modifica su código.

Objetivo propuesto: permitir consulta de un subconjunto autorizado previamente descargado y captura local de borradores sin confundir guardado local con aceptación empresarial. No se habilitan reservas de stock, facturación, compras, ajustes, conciliación definitiva, notificaciones ni acceso corporativo. La continuidad offline requiere una primera visita online exitosa; un dispositivo sin instalación/caché previa no tiene garantía de arranque offline.

## 2. Funcionalidades verificadas por inspección

| Componente y ubicación relativa al frontend oficial | Evidencia de código | Límite |
|---|---|---|
| vite.config.ts | VitePWA autoUpdate; precaché JS/CSS/iconos/fuentes; navegaciones NetworkFirst y assets CacheFirst; navigateFallback null; SW deshabilitado en dev | No demuestra arranque offline en rutas nunca visitadas; tampoco guarda transacciones de negocio. |
| src/lib/registerServiceWorker.ts y src/routes/__root.tsx | Registro /sw.js solo en producción admitida; excluye iframe, ciertos previews y sw=off | Las pruebas deberán usar build de producción y contexto admitido. |
| src/hooks/useOnlineStatus.ts y components/layout/Header.tsx | Escucha navigator.onLine y eventos online/offline; el encabezado promete guardado local de conteos | Indicador de red, no disponibilidad API. La promesa de persistencia no está respaldada por el mockStore. |
| src/services/api/apiClient.ts | Mocks activos por defecto; fetch real con Bearer en memoria y URL por entorno | No hay outbox durable, reintentos persistentes ni idempotencia. No desactivar globalmente mocks para probar solo catálogo. |
| src/services/mockStore.ts | Productos, conteos, cotizaciones, movimientos y stock dinámico en objetos en memoria | Reiniciar el contexto vuelve al fixture; no se identificó IndexedDB en el código inspeccionado. |
| src/context/AuthContext.tsx y services/auth.service.ts | Sesión en sessionStorage, JWT ficticio, login demo, switchRole local | No es autorización empresarial; expiración inválida puede superar el control actual. Cerrar sesión no equivale a borrar todos los datos offline futuros. |
| src/services/inventory.service.ts | Conteos mock actualizan physicalStock; historial limitado a 200 entradas | No genera un conteo aceptado por backend ni prueba durabilidad. |
| src/services/quotes.service.ts y features/ventas/quoteExport.ts | Cotizaciones en memoria con version incrementada localmente; Excel de importación dinámica y PDF/impresión | version no es control de concurrencia en servidor; exportar offline necesita recursos previamente disponibles. |
| src/services/movements.service.ts | Registrar movimiento no altera stock deliberadamente | Offline no puede inferir cambios de stock empresarial. |
| src/services/reconciliation.service.ts | Ajustes mock modifican store.dynamicStock | No autoriza ajustes offline reales. |
| src/services/dashboard.service.ts | KPI y avisos calculados sobre mocks | No representa monitoreo empresarial actualizado offline. |
| src/services/auditLogger.service.ts | sessionStorage, hash simple y envío sin cola persistente | No garantiza integridad, entrega ni auditoría del servidor. |
| Backend/Program.cs, Controllers y README (Dayr-App) | /health de proceso; /v1/inventory/products sintético solo Development; no-store global; CORS GET y headers Content-Type/Authorization; ProblemDetails | No hay persistencia, login empresarial, endpoints de escritura/sync, deduplicación ni control de versiones. |

No se marca ningún hallazgo de auditoría previo como corregido. Instalable/PWA, indicador sin red y operación empresarial offline son capacidades distintas. La documentación histórica del frontend viejo menciona localStorage; no acredita durabilidad del frontend oficial.

## 3. Política propuesta por módulo

| Módulo | Consulta offline propuesta | Escritura propuesta / límites |
|---|---|---|
| Catálogo/Almacén | Snapshot autorizado con fuente, unidad, fecha y vigencia visibles | Sin alterar stock. Stock físico, ERP y dinámico se conservan separados; fuente oficial pendiente. |
| Conteos | Consultar captura propia y catálogo mínimo | Captura provisional local por sesión de conteo, producto, ubicación y unidad; no sustituye inventario hasta validación online. Requiere aprobación del proceso. |
| Ventas/Cotizaciones | Catálogo y clientes mínimos autorizados; documentos propios permitidos | Borradores, sin numeración oficial ni precio/stock garantizados; aceptación, precios, impuestos y permisos se revalidan en servidor. No POS/caja ni venta definitiva offline. |
| Movimientos | Historial autorizado con fecha de corte | Como máximo borrador no operativo tras aprobación; confirmación solo online. |
| Conciliación | Snapshot de discrepancias identificado como histórico | Aprobar ajustes y resolver diferencias solo online. |
| Dashboard/alertas | Datos derivados del snapshot con aviso de antigüedad y ámbito | Sin prometer monitoreo real; vencido/no evaluable no significa Normal. Respeta diseño de alertas pendiente. |
| Auditoría | Estado de entrega de eventos locales mínimos | Telemetría pendiente separada de auditoría autoritativa; servidor genera registro de acciones aceptadas. |
| Autenticación/roles | Uso local restringido de acceso previamente autorizado, solo si la empresa lo aprueba | Sin login inicial offline, contraseñas locales ni elevación de rol; reautenticación para enviar. |

## 4. Arquitectura propuesta y separación de responsabilidades

UI React -> servicios de dominio -> repositorio local IndexedDB y coordinador de sincronización -> apiClient -> API ASP.NET Core -> persistencia futura autorizada. Service worker: shell y assets públicos, no reglas empresariales. No se crea otro backend. Acceso a IndexedDB únicamente en cliente, protegido ante SSR/ausencia de window y errores de almacenamiento; nada de conexiones de BD en importaciones de servidor. Mantener servicios como frontera sin incrustar fetch/IDB en pantallas.

No se selecciona aún una librería: evaluar API nativa frente a idb/Dexie según migraciones, pruebas y mantenimiento. No instalar dependencias en esta actividad.

### Esquema conceptual IndexedDB (no tablas SQL implementadas)

| Store propuesto | Clave / datos mínimos | Política |
|---|---|---|
| metadata | versión de esquema, versión app, entorno, sujeto, ámbito, última sincronización, cursores | Separación por entorno/API y usuario/organización/almacenes si aplica; no presumir multitenencia ya existente. |
| snapshots | clave compuesta ámbito/tipo/id; payload mínimo, source, fetchedAt, expiresAt, serverVersion | Solo datos permitidos; etiquetas de vigencia; no mezclar físico/ERP/dinámico. |
| drafts | clientEntityId UUID, dueño, tipo, payload, baseVersion, estado local | Guardado atómico; versión de contrato; sin credenciales. |
| outbox | operationId UUID, clientEntityId, tipo permitido, payload canónico, payloadHash, baseVersion, dependsOn, ownerScope, schemaVersion, createdAt, attempts, nextAttemptAt, leaseUntil, estado, último código | No almacenar requests arbitrarios, URL libre, Authorization, tokens ni cookies. |
| receipts | operationId, serverId, serverVersion, acceptedAt, resultado mínimo | Conservación limitada a la ventana de deduplicación aprobada; sin borrar prematuramente pendientes. |
| conflicts | operationId, versiones base/local/servidor y motivo mínimo | Acceso restringido; resolución explícita y auditada. |

Guardar borrador y entrada outbox en una transacción IDB cuando se apruebe el envío, para evitar estados a medias. Esperar confirmación de commit antes de mostrar “Guardado en este dispositivo”. Una captura puede seguir solo como borrador hasta que el usuario decida enviarla; no todo autoguardado debe crear una mutación remota. No decir “Sincronizado” hasta tener recibo aceptado.

### Shell, SSR y almacenamiento

Proponer shell offline público específico/fallback que no contenga HTML SSR personalizado. Excluir login, OAuth, respuestas autenticadas y errores de caché de navegación; revisar la regla NetworkFirst actual que abarca navegaciones. No cachear Authorization ni respuestas de otro usuario. Cambiar a un snapshot empresarial persistido exige autorización explícita de política de datos; no usar Cache API para sortear el no-store actual del backend. Hoy solo se puede ensayar con fixtures.

Precargar recursos necesarios, incluidas dependencias lazy de escáner/exportación cuando se autorice; rutas nunca visitadas y descarga/impresión requieren pruebas. Actualizar SW avisando al usuario y guardando borradores antes de recargar; compatibilidad entre versiones de app, esquema IDB y contrato; no borrar outbox al activar una nueva caché. En migración fallida abrir modo seguro con recuperación, no reinicializar destructivamente.

Consultar cuota estimada y solicitar persistencia cuando proceda; el navegador puede rechazarla. Manejar QuotaExceededError, modo privado, BD bloqueada y evicción. Nunca garantizar durabilidad absoluta ni borrar pendientes para liberar espacio: depurar primero snapshots recuperables y detener nuevas capturas con mensaje claro si no es posible guardar. Política de recuperación/exportación cifrada pendiente; no exportar datos sensibles automáticamente.

## 5. Cola y algoritmo de sincronización propuestos

Estados: BORRADOR (sin envío), PENDIENTE, ENVIANDO con lease, REINTENTO, BLOQUEADA_AUTH, CONFLICTO, RECHAZADA, CONFIRMADA. La caída del navegador vence el lease y permite reintento con el mismo operationId; no inventar éxito. Cancelar solo una operación aún no enviada; si su aceptación es incierta consultar recibo antes de cancelar o generar una compensación aprobada.

Disparadores: acción manual, inicio de app, regreso a primer plano y recuperación de conectividad. navigator.onLine es pista; comprobar API real y credenciales con timeout. /health solo acredita proceso, no permiso, disponibilidad de escrituras o ERP. Background Sync es mejora opcional con detección de soporte, nunca requisito único; no prometer sincronización con app cerrada.

1. Cargar operaciones del mismo dueño/entorno; verificar esquema, vigencia y dependencias.
2. Obtener sesión real vigente online; no persistir token dentro de outbox. Revalidar permisos en cada envío.
3. Reclamar operaciones con lease atómico IDB; Web Locks/BroadcastChannel opcionales para coordinación de pestañas, sin confiar en ellos como garantía de unicidad remota.
4. Procesar secuencialmente por entidad y dependencias, con concurrencia acotada para entidades independientes. Un padre rechazado bloquea sus dependientes, no toda la cola.
5. Enviar payload inmutable y operationId; nueva intención editada genera operación nueva. No colapsar conteos/movimientos ni reordenar eventos sin reglas aprobadas.
6. Confirmar solo tras respuesta/recibo; actualizar recibo, snapshot y estado en transacción local. Si cae después de aceptación remota, repetir misma clave permite recuperar resultado sin repetir efecto.
7. Refrescar snapshots y cursores tras confirmaciones; persistir cursor solo al aplicar todo el lote, incluir tombstones para bajas. Primer diseño puede usar snapshot completo paginado consistente; delta/cursor futuro requiere contrato explícito.

Red/timeout/408/429/5xx: backoff exponencial con jitter y tope, respetar Retry-After; número de intentos y retención pendientes. Fallo TLS no se arregla omitiendo validación. 401: pausar y reautenticar; 403: bloquear/revisar permiso, sin bucle de retries. 400/422: error de validación corregible explícitamente; 409/412: conflicto, sin sobrescribir. 404 de producto eliminado: revisión, no recrear automáticamente. Respuesta parcial de lote exige resultado por operationId; no marcar todo el lote confirmado. Proponer operaciones individuales primero.

## 6. Prevención de duplicados y conflictos

La entrega será al menos una vez; no se promete exactly-once de red. operationId generado una vez mediante UUID criptográfico, mantenido tras recarga/reintento; deshabilitar doble clic mejora UX pero no sustituye idempotencia. El servidor debe vincular clave a sujeto/ámbito/tipo, comparar hash de payload validado y aplicar unicidad durable. Misma clave y mismo payload devuelve resultado previo; misma clave y payload distinto devuelve conflicto. Efecto empresarial, recibo y auditoría deben confirmarse atómicamente en la persistencia futura; ante procesamiento concurrente, uno reclama y otro recibe estado consultable/reintento. La ventana de retención debe cubrir el máximo periodo offline/reintentos; claves expiradas no deben reenviarse a ciegas. Si aún no existe persistencia transaccional, no habilitar envíos empresariales offline.

| Entidad | Concurrencia y resolución propuestas |
|---|---|
| Catálogo | Servidor como autoridad solo de ese snapshot autorizado; invalidar por versión/baja. No modificar cantidades empresariales desde cliente. |
| Cotización | ETag fuerte/If-Match o versión explícita en comando; conflicto muestra base/local/remoto. Sin last-write-wins para importes/estado. Fusionar solo campos demostrablemente independientes tras reglas aprobadas. |
| Conteo | Observación inmutable con sesión de conteo, ubicación, unidad y versión base; dos conteos no se suman ni se elige el último por reloj del dispositivo. Responsable de Almacén revisa según política. |
| Movimiento/ajuste | Confirmación online con permisos y versión; no fusionar cantidades. Propuesta offline solo borrador. |

Tiempos de dispositivo son informativos: acceptedAt/versión del servidor mandan para aceptación; reloj desviado no decide ganadores. Identidad, countedBy, responsible y approvedBy provienen de credenciales verificadas, no de nombres enviados por cliente. Se conserva quién capturó y quién confirmó cuando difieran, con política de delegación pendiente. Sin reasignar pendientes automáticamente al nuevo usuario.

## 7. Autenticación, privacidad y seguridad

El login/JWT demo y switchRole no habilitan uso empresarial. Propuesta conservadora: primer login online, sin acceso offline nuevo tras expiración; ventana offline más amplia solo tras análisis y aprobación. Cerrar navegador elimina sessionStorage, por lo que las capturas locales deberán permanecer bloqueadas hasta reautenticación del mismo sujeto. Revocación inmediata es imposible de comprobar sin red; si se exige, prohibir acceso offline sensible.

No almacenar contraseñas, refresh/access tokens o secretos en IDB/localStorage/outbox. Selección entre cookie HttpOnly Secure SameSite con protección CSRF y token corto en memoria depende de arquitectura de orígenes e identidad aún no definida; no simular una solución existente. Al recuperar red revalidar permisos, almacenes, estado de producto y vigencia, incluso si el usuario pudo capturar localmente.

Aislamiento de datos por usuario/entorno, bloqueo inmediato en logout/cambio de cuenta y limpieza de snapshots/cachés personalizadas. Política de pendientes al salir requiere decisión: no descartarlos silenciosamente ni permitir que la siguiente cuenta los lea/envíe. Proponer retención bloqueada para mismo dueño con plazo aprobado y advertencia antes de salir; sin mecanismo de protección aceptable en equipo compartido, impedir capturas sensibles persistentes. Retención, borrado seguro y recuperación requieren validación empresarial. El navegador no garantiza borrado forense.

IndexedDB no es bóveda: XSS o acceso al perfil/dispositivo pueden exponer datos. Cifrar con clave almacenada junto al contenido no protege frente a XSS; cifrado con claves gestionadas/desbloqueo del usuario requiere diseño de recuperación y no se declara implementado. Minimización de clientes/precios/DNI, CSP, sanitización, dependencias mantenidas, HTTPS estricto y equipos administrados. No colocar datos sensibles en logs, query strings ni errores. Auditoría local es no confiable: servidor deriva actor y registra recepción/aceptación con operationId y traceId. No afirmar cumplimiento ISO por usar hash o IndexedDB.

## 8. Responsabilidades futuras del backend original (NO implementadas)

Mantener solución .NET 10. Primero autenticación/autorización y persistencia propia autorizada; después comandos de negocio con idempotencia durable, versiones, validación, recibos consultables, trazabilidad y ámbito de almacenes. Propuestas de contratos, no rutas aprobadas: comandos individuales de conteos/cotizaciones con operationId, baseVersion y versión de esquema; respuesta operationId/serverId/serverVersion/acceptedAt. Endpoint de estado de operación y feed de cambios deben definirse con OpenAPI antes de implementarse. Ninguna ruta /sync se declara disponible.

El CORS actual solo GET no permite esas escrituras: una fase futura deberá aprobar métodos y headers exactos (por ejemplo Idempotency-Key/If-Match), exponer ETag y mantener orígenes restringidos. no-store actual se conserva: política de caché/persistencia offline necesita revisión explícita. ProblemDetails con códigos de conflicto/validación estables, sin secretos; rechazar versiones de contrato incompatibles. No depender de e-SOFTCOM para pruebas iniciales ni afirmar que está conectado.

## 9. Plan y decisiones pendientes

Fase A: validar datos, dispositivos, ámbitos, ventana offline, roles y reglas de captura; aprobar contratos. Fase B: primera integración selectiva con catálogo sintético y shell offline, sin escrituras empresariales. Fase C: prototipo IndexedDB y borradores ficticios, recuperación/migración/cuota. Fase D: autenticación/persistencia/idempotencia/versiones de servidor y ensayos de fallos. Fase E: piloto autorizado y ampliación por módulo. Las alertas quedan sujetas a su diseño y aprobación separados.

Decisiones de Almacén/Gestión/Ventas/Sistemas: stock oficial y vigencia; datos y almacenes descargables; quién captura/revisa conteos y cómo resuelve duplicidad semántica; cotizaciones permitidas offline, precios y numeración; roles y revocación; equipos personales/compartidos; retención, cuotas, pérdida del equipo y recuperación; navegadores/versiones mínimos; ventana offline e idempotencia; responsables de conflictos y soporte; autorización de cualquier conexión corporativa. No fijar TTL, tamaños máximos, intentos o tiempos de bloqueo como si fueran reglas aprobadas.

## 10. Validación y entregables

La matriz adjunta describe pruebas futuras con datos sintéticos, criterios y evidencia requerida. En esta actividad solo se verifican fuentes, referencias y preservación documental; no se ejecutan esas pruebas ni se reutilizan los 23 PASS del acondicionamiento como prueba de offline. No se modifican C#, TypeScript, SW, configuraciones, tablas o endpoints. No hay nuevas conexiones corporativas ni cambios en ClickUp.

## 11. Referencias técnicas oficiales consultadas el 23/10/2026

- [IndexedDB](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API): almacenamiento estructurado transaccional por origen.
- [Storage API](https://developer.mozilla.org/en-US/docs/Web/API/Storage_API): estimación y persistencia sujetas al navegador.
- [Background Sync](https://developer.mozilla.org/en-US/docs/Web/API/Background_Synchronization_API): soporte limitado y contexto seguro; requiere alternativa en primer plano.
- [ETag](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/ETag): If-Match y 412 como base de concurrencia optimista.
- [Errores ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/error-handling?view=aspnetcore-10.0): manejo estructurado y diagnóstico.

Las referencias justifican mecanismos técnicos; las reglas de negocio descritas como propuestas requieren aprobación.
