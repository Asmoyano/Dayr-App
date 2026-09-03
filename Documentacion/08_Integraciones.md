# 08. Estrategia de Integración de Datos

## Arquitectura de Middleware (Patrón Repository)
Para garantizar la independencia entre la base de datos y la interfaz del usuario:

```text
[ React PWA ] <---> [ Web API Controller ] <---> [ IRepository Interface ]
                                                         |
                                        +----------------+----------------+
                                        |                                 |
                            [ SQLServerRepository ]            [ GoogleSheetsRepository ]