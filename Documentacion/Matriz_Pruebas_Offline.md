# Sistema DAYR PWA - Matriz preliminar de pruebas offline

**23/10/2026 | PROPUESTA | Ninguna prueba funcional de esta matriz fue ejecutada.**

Referencia: [diseño técnico](Diseno_Preliminar_Funcionamiento_Offline.md). P0 bloquea piloto; P1 exige resolución antes de aceptar el módulo afectado. Responsabilidad propuesta: QA/Frontend para cliente, QA/Backend para API, Seguridad para aislamiento/identidad; Almacén/Ventas validan resultados de negocio. Asignación nominal pendiente.

## Preparación y registro

Entorno aislado con fixtures, dos cuentas ficticias A/B y ámbitos distintos, dos dispositivos/pestañas, builds y commits identificados. Servidor de pruebas con persistencia idempotente y fallos controlados cuando exista; no usar ERP/BD corporativa. Probar build de producción admitido por el registro SW; localhost/dev sin SW no demuestra funcionamiento publicado. Registrar navegador/versión, sistema, build, versión SW/IDB/contrato, fecha/zona, pasos exactos, resultado esperado/observado, logs sanitizados, operationId/traceId y evidencia de número de efectos en servidor. No guardar secretos en capturas.

Estado para todos los casos: **NE (no ejecutado)**. Los que requieren autenticación, escrituras, versiones y persistencia están además **bloqueados por capacidades futuras del backend**; las pruebas de UI/IDB requieren el prototipo futuro. Esta tabla no contiene PASS del trabajo previo.

| ID | Prioridad | Área | Estímulo / pasos a reproducir en entorno de prueba | Resultado esperado | Estado |
|---|---|---|---|---|---|
| OFF-01 | P0 | Shell | Visita online previa y recarga sin red | Abre shell autorizado y avisa modo offline; no promete API | NE |
| OFF-02 | P0 | Primer acceso | Perfil limpio sin red | Mensaje recuperable; no inventa catálogo ni sesión | NE |
| OFF-03 | P1 | Rutas | Abrir ruta nunca visitada offline | Fallback público seguro o indisponibilidad explícita; sin HTML ajeno | NE |
| OFF-04 | P0 | SSR | Renderizar servidor sin window/IDB | Sin excepción ni datos locales de otro usuario | NE |
| OFF-05 | P0 | Disponibilidad | navigator.onLine true y API caída | Distingue red/API; no muestra sincronizado | NE |
| OFF-06 | P0 | Catálogo | Snapshot vigente/vencido y campos físico/ERP/dinámico | Fuente y fecha visibles; vencido no se asume stock actual | NE |
| OFF-07 | P0 | Durabilidad | Guardar captura y cerrar/reabrir | Tras commit IDB conserva borrador y estado pendiente; nunca falso éxito | NE |
| OFF-08 | P0 | Atomicidad | Interrumpir transacción borrador/outbox | Ambos persistidos o ninguno; sin operación huérfana | NE |
| OFF-09 | P0 | Cuota | Provocar quota/mode privado/IDB denegado | Advierte y bloquea guardado ficticio; no borra pendientes | NE |
| OFF-10 | P0 | Evicción | Eliminar almacenamiento del sitio | Detecta ausencia; no promete recuperación imposible; protocolo de soporte | NE |
| OFF-11 | P0 | Actualización | Actualizar SW/app con cola pendiente | Sin pérdida ni recarga destructiva; esquema compatible | NE |
| OFF-12 | P0 | Migración | Migración IDB fallida y otra pestaña abierta | Modo seguro/blocked con instrucción; no reinicializa BD | NE |
| OFF-13 | P0 | Idempotencia | Servidor acepta y se pierde respuesta; reenviar misma clave | Un solo efecto; recupera mismo recibo | NE |
| OFF-14 | P0 | Concurrencia | Enviar misma operación desde dos pestañas/SW | Un efecto durable pese a carreras; leases recuperables | NE |
| OFF-15 | P0 | Clave reutilizada | Misma clave con distinto payload | Conflicto; no aplica segundo efecto | NE |
| OFF-16 | P0 | Caducidad | Reenviar operación más antigua que retención de clave | Revisión/consulta, sin crear duplicado a ciegas | NE |
| OFF-17 | P1 | Reintentos | Timeout/429 Retry-After/503 | Backoff con jitter y pausa; mismo operationId | NE |
| OFF-18 | P0 | TLS | Certificado inválido | Bloquea envío; sin omitir validación TLS | NE |
| OFF-19 | P0 | Sesión | 401 o sesión expirada al volver online | Pausa; reautentica mismo sujeto antes de envío | NE |
| OFF-20 | P0 | Permisos | 403/rol o almacén revocado | Rechaza/revisa; no bucle ni elevación desde cliente | NE |
| OFF-21 | P0 | Cuenta | Logout A, login B con pendientes de A | B no ve ni envía datos de A; no pérdida silenciosa | NE |
| OFF-22 | P0 | Manipulación | Cambiar countedBy/approvedBy/rol local | Servidor deriva identidad/permisos; actor falsificado no manda | NE |
| OFF-23 | P0 | Concurrencia entidad | Dos versiones editan misma cotización | 412/409 y revisión base/local/remoto; sin sobrescritura automática | NE |
| OFF-24 | P0 | Conteos | Dos dispositivos cuentan mismo producto | No suma ni last-write-wins; revisión según regla aprobada | NE |
| OFF-25 | P0 | Dependencias | Padre falla y existen operaciones hijas | Bloquea dependientes; independientes pueden continuar | NE |
| OFF-26 | P1 | Validación | 400/422 y producto eliminado 404 | Error visible corregible; sin retries ciegos ni recreación automática | NE |
| OFF-27 | P0 | Confirmación local | Caída tras recibir ACK antes de guardar receipt | Reintento idempotente recupera estado; no segundo efecto | NE |
| OFF-28 | P1 | Lectura incremental | Corte a mitad de página/cursor y tombstone | Cursor solo avanza con commit; baja aplicada sin resucitar entidad | NE |
| OFF-29 | P0 | Reloj | Fecha de dispositivo adelantada/atrasada | No decide ganador ni aceptación por hora cliente | NE |
| OFF-30 | P0 | Datos sensibles | Inspeccionar IDB/Cache/logs tras uso/logout | Sin tokens/contraseñas ni HTML de otro usuario; política de pendientes aplicada | NE |
| OFF-31 | P0 | XSS | Texto ficticio con etiquetas/script en borrador/conflicto | Se muestra como dato; no ejecución ni filtración | NE |
| OFF-32 | P1 | Navegadores | Edge/Chrome y Safari/iOS/Firefox según parque aprobado | Fallback primer plano sin depender de Background Sync | NE |
| OFF-33 | P1 | Exportación | Excel lazy y PDF/impresión sin red | Recursos disponibles o error claro; borrador identificado, no documento oficial | NE |
| OFF-34 | P0 | Reglas de negocio | Intentar confirmar movimiento/ajuste offline | Bloqueado; no altera stock ni simula aprobación | NE |
| OFF-35 | P1 | Alertas | Snapshot vencido o no evaluable | No declara Normal ni monitoreo real | NE |
| OFF-36 | P0 | CORS | Preflight de futuras escrituras con origen no autorizado | Deniega; origen aprobado solo con métodos/headers acordados | NE |
| OFF-37 | P1 | Auditoría | Aceptación de comando y evento local repetido | Servidor registra actor/operationId una vez por efecto; local no es prueba autoritativa | NE |
| OFF-38 | P0 | Contrato | Cola antigua con schemaVersion no soportada | Bloquea y ofrece recuperación; sin descartar/migrar silenciosamente | NE |

## Evidencias exigidas y criterios de salida

- UI/almacenamiento: captura antes/después, recarga real y volcado mínimo sanitizado de estados IDB/caché, sin payload empresarial.
- Envíos: traza por operationId, respuestas y consulta de recibo; contar efectos remotos para demostrar deduplicación. El estado local por sí solo no prueba entrega.
- Conflictos: conservar versiones y decisión visible; sin publicar información sensible.
- Seguridad: demostrar aislamiento A/B y rechazo de actor/ámbito falsificado en servidor; inspección del cliente no basta.
- No habilitar piloto si falla algún P0; documentar P1 por módulo, responsables y aceptación. Navegadores, SLA, TTL y límites de datos quedan por aprobar antes de cerrar criterios cuantitativos.

## Comprobaciones documentales realizadas en esta actividad

Se inspeccionaron los archivos indicados en el diseño, se comparó el commit del frontend con main remoto y se revisó el backend original y su Git. Se generaron solo dos Markdown. La verificación de preservación y publicación de esos documentos se registra por separado al finalizar, sin presentar ensayos propuestos como ejecutados.
