# Backend DAYR - acondicionamiento inicial

Esta es la solución existente Backend.slnx / Backend.csproj (.NET 10). No requiere una base de datos para estas pruebas y no se conecta con e-SOFTCOM.

## Ejecutar en Visual Studio

1. Abrir Backend.slnx y seleccionar el perfil **https** (puertos HTTPS 7216 y HTTP 5292).
2. Restaurar paquetes, compilar y ejecutar. Abrir https://localhost:7216/health.
3. En Development, consultar https://localhost:7216/v1/inventory/products y https://localhost:7216/openapi/v1.json. También se pueden enviar las solicitudes de Backend.http.

Por terminal: dotnet restore, dotnet build y dotnet run --launch-profile https, desde Backend/.

La validación de certificados permanece activada. Si el cliente no confía en el certificado de desarrollo, comprobarlo con dotnet dev-certs https --check y seguir el procedimiento autorizado de confianza del equipo. No usar opciones para omitir validación TLS. El perfil HTTP se conserva, pero ahora redirige al puerto HTTPS de Development; no demuestra que el certificado sea de confianza.

## Endpoints y límites

- GET /health devuelve status, service, timestampUtc, scope=Process y dataMode. Solo informa que el proceso responde: no certifica conexión ni disponibilidad de ERP/SQL.
- GET /v1/inventory/products devuelve un array Product[] directo, camelCase, con tres productos claramente ficticios. Los campos erpStock son valores de prueba; no lecturas empresariales. No permite escrituras.
- El catálogo requiere Development y SyntheticCatalog:Enabled=true. La configuración base lo deshabilita. Fuera de Development responde 404; intentar habilitarlo fuera de ese entorno impide el arranque.
- OpenAPI está disponible solo en Development. No se añadió Swagger UI ni se necesita otra solución/proyecto.
- El controlador WeatherForecast original se conserva como ejemplo; no es una función empresarial.

## Configuración por entorno

appsettings.json define catálogo deshabilitado, hosts de loopback y CORS sin orígenes permitidos. appsettings.Development.json habilita el fixture y permite exclusivamente http://localhost:5173 y http://127.0.0.1:5173. Ajustar la allowlist si se autoriza otro origen local: esquema, host y puerto deben coincidir exactamente, sin barra final/rutas/comodines.

Solo GET se permite en CORS; se admiten Content-Type y Authorization como headers de petición para compatibilidad de transporte. Eso no implementa autenticación ni da permisos. Se expone X-Correlation-ID al origen permitido. No hay credenciales CORS ni wildcard. Fuera de Development los orígenes configurados deben usar HTTPS.

Las variables de entorno pueden sustituir configuración (por ejemplo Cors__AllowedOrigins__0, SyntheticCatalog__Enabled y HttpsRedirection__HttpsPort). No colocar secretos en archivos versionados. AllowedHosts se restringe a localhost/loopback: el despliegue real necesita una política de hosts y seguridad específica antes de usar datos reales.

## Errores, logging y comprobación

404/405 y excepciones se devuelven como application/problem+json con status, title y traceId, sin stack público. X-Correlation-ID identifica la solicitud y coincide con traceId. Las respuestas llevan Cache-Control: no-store. El log básico incluye método, ruta sin query, estado y duración; no registra cuerpos, contraseñas o tokens. No es una bitácora transaccional de negocio.

Ejecutar el smoke con el backend iniciado: pwsh -File scripts/Test-LocalApi.ps1 -BaseUrl https://localhost:7216. El script mantiene TLS estricto y prueba contrato, OpenAPI, CORS y errores404/405. No prueba autenticación empresarial ni provoca excepciones artificiales500.

El frontend oficial no se modificó. No desactivar todos sus mocks todavía: login y los demás contratos de negocio no existen en esta fase. Una futura integración selectiva debe indicar explícitamente que el catálogo es sintético.

No se implementaron autenticación empresarial, persistencia, cotizaciones, conciliación, integraciones ERP ni sincronización offline. Este acondicionamiento no declara cerrados los hallazgos de la auditoría ni habilita uso de información corporativa real.
