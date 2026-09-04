# Dayr App — Ventas y Almacén

Aplicación web para Dayr: sistema de Ventas y Almacén, con backend en ASP.NET Core Web API y frontend en Vite + TypeScript + React, con soporte offline (PWA).

## Estado actual

En construcción — fase de infraestructura base. Ver [`Documentacion/11_Estado_Actual.md`](./Documentacion/11_Estado_Actual.md) para el detalle exacto de qué está implementado y qué falta.

La planificación, el levantamiento de información y las decisiones técnicas del proyecto están documentadas en la carpeta [`Documentacion/`](./Documentacion/).

## Stack tecnológico

| Capa | Tecnología |
|---|---|
| Backend | ASP.NET Core Web API (.NET 10) |
| Frontend | Vite + React 19 + TypeScript |
| Offline / PWA | `vite-plugin-pwa` |
| Base de datos | SQL Server (pendiente de conectar) |

## Estructura del repositorio

```text
Dayr-App/
├── Backend/            → API en C# / ASP.NET Core
├── Frontend/            → App web en React + TypeScript (Vite)
├── Documentacion/       → Investigación, requerimientos y decisiones del proyecto
└── README.md            → Este archivo
```

## Cómo levantar el proyecto en local

### Requisitos

- .NET SDK 10 o superior
- Node.js 18 o superior
- Visual Studio Community (recomendado, ambos proyectos ya están preparados para abrirse ahí)

### 1. Backend

```bash
cd Backend
dotnet restore
dotnet run
```

La API queda disponible en `https://localhost:7216` (ver `Backend/Properties/launchSettings.json` para el puerto exacto).

### 2. Frontend

```bash
cd Frontend
npm install
npm run dev
```

La app queda disponible en el puerto configurado en `Frontend/vite.config.ts` (actualmente `57194`).

> Con ambos corriendo, el frontend consulta el endpoint de prueba del backend y muestra en pantalla si la conexión fue exitosa — es la prueba de humo (*smoke test*) actual del proyecto.

## Documentación relacionada

- [`Backend/README.md`](./Backend/README.md) — detalle técnico del backend
- [`Frontend/README.md`](./Frontend/README.md) — detalle técnico del frontend
- [`Documentacion/`](./Documentacion/) — objetivo, alcance, módulos de e-SOFTCOM, procesos, entrevistas, integraciones, seguridad y decisiones