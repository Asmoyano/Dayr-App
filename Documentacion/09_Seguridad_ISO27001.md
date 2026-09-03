# 09. Cumplimiento Normativo ISO 27001 (Anexo A)

## Control A.9: Control de Acceso
* Implementación de autenticación basada en tokens JWT con tiempos de expiración definidos.
* Roles estrictos: `Administrador`, `VendedorCampo`, `Almacenero`.

## Control A.10: Criptografía
* Obligatoriedad de HTTPS (TLS 1.2+) para todo el tráfico de datos.
* Encriptación de datos sensibles persistidos localmente en el navegador (IndexedDB).

## Control A.12: Seguridad de las Operaciones
* Registro detallado de logs de auditoría en la API (quién creó, modificó o eliminó cada registro).