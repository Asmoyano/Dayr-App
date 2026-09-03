# 01. Objetivo del Proyecto

## Objetivo General
Desarrollar e implementar dos aplicaciones web progresivas (PWA) —una para la Gestión de Ventas en Campo y otra para la Gestión de Almacén— conectadas a un middleware API en .NET Core que interactúe con el sistema e-SOFTCOM SQL v21.53, garantizando operatividad offline y cumplimiento normativo ISO 27001.

## Objetivos Específicos
* **Autonomía Operativa:** Permitir que los vendedores de campo y el personal de almacén registren operaciones aun cuando no dispongan de conectividad a internet.
* **Aislamiento Arquitectónico:** Construir un backend middleware utilizando el patrón Repository para abstraer la base de datos legacy (SQL Server 2014) y facilitar futuras migraciones (e.g., Google Sheets).
* **Seguridad y Auditoría:** Asegurar el control de acceso basado en roles (RBAC) y la trazabilidad de eventos según el Anexo A de la norma ISO 27001.