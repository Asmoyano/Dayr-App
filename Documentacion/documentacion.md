# Documentación del Proyecto: Aplicación Web / PWA con React + .NET

## 1. Visión General del Proyecto
* **Nombre del Proyecto:** [Nombre de tu proyecto o solución]
* **Objetivo:** Desarrollo de una solución web moderna (Progressive Web App) con soporte para funcionamiento offline y sincronización con backend.
* **Integrantes / Desarrollo:** Adolfo Moyano

---

## 2. Arquitectura de la Solución

### Stack Tecnológico
* **Frontend:**
  * React + TypeScript (Vite)
  * PWA / Service Worker (En progreso)
* **Backend:**
  * ASP.NET Core Web API (C#)
  * HTTPS habilitado
  * CORS configurado para comunicación segura con el cliente
* **Almacenamiento Local (Cliente):**
  * LocalStorage / IndexedDB (Fase 3)

---

## 3. Registro de Fases de Desarrollo

### Fase 1: Configuración del Entorno de Desarrollo
* [x] Inicialización del repositorio de frontend con Vite, React y TypeScript.
* [x] Creación de la solución Web API en C# (.NET Core).
* [x] Verificación de herramientas de compilación y dependencias.

### Fase 2: Infraestructura y Prueba de Humo (Smoke Test)
* [x] Configuración de HTTPS y puertos de comunicación en el backend.
* [x] Habilitación y prueba de políticas CORS para permitir peticiones desde Vite.
* [x] Creación de servicios del cliente (`src/services/api.ts`) usando Fetch/TypeScript.
* [x] Implementación exitosa de consumo de endpoint (`WeatherForecast`).
* [x] Implementación del detector reactivo de conectividad (`NetworkStatus.tsx`) para la escucha de eventos `online` / `offline`.

### Fase 3: Soporte PWA y Modo Offline (En Progreso)
* [ ] Configuración del Manifiesto de la Aplicación (`manifest.webmanifest`).
* [ ] Registro e integración de Service Worker.
* [ ] Configuración de estrategias de caché para assets estáticos.
* [ ] Implementación de almacenamiento local persistente (IndexedDB).

### Fase 4: Lógica de Negocio y Persistencia
* [ ] Definición de modelos de datos principales.
* [ ] Desarrollo de componentes UI definitivos.
* [ ] Endpoints de lectura y escritura en la Web API.

---

## 4. Guía de Ejecución Local

### Prerrequisitos
* Node.js (v18+)
* .NET SDK (.NET 8 u 8+)

### Pasos para Ejecutar

1. **Iniciar Backend (ASP.NET Core Web API):**
   ```bash
   cd ruta/al/backend
   dotnet run
* URL base: "https://localhost:[puerto_backend]"

2. **Iniciar Frontend (React + Vite):**
   ```bash
   cd ruta/al/frontend
   npm run dev
* URL base: "https://localhost:[puerto_frontend]"
    
## 5. Historial de Cambios / Bitácora

* **03/09/2026 — Inicialización de Arquitectura y Configuración del Frontend:**
  * Configuración del proyecto base con React, TypeScript y Vite.
  * Elección explícita de **ESLint** sobre Oxlint para garantizar compatibilidad con reglas de React Hooks y cumplimiento de estándares de código.
  * Decisión de desacoplar los entornos de desarrollo (VS Code para el Frontend y Visual Studio Community para el Backend) resolviendo el bloqueo de archivos de índice (`EBUSY` en `.vs`).

* **03/09/2026 — Configuración del Middleware API y Seguridad de Comunicación:**
  * Creación del proyecto base en ASP.NET Core Web API en C#.
  * Habilitación y prueba de la política de CORS (`AllowReact`) para permitir peticiones HTTP transversales de orígenes locales de desarrollo.
  * Instalación y registro del certificado SSL para HTTPS local (`https://localhost:7216`).

* **03/09/2026 — Validación de Integración End-to-End (Smoke Test):**
  * Implementación del servicio de integración en `src/services/api.ts` con control de errores tipados mediante la interfaz `WeatherForecast`.
  * Renderizado exitoso de datos mock provenientes del controlador C# dentro del árbol de componentes de React.
  * Corrección de importaciones explícitas de tipos (`import type`) exigidas por la regla `verbatimModuleSyntax` de TypeScript.

* **03/09/2026 — Infraestructura para Capacidades Offline (PWA Ready):**
  * Creación del componente `NetworkStatus.tsx` encargado de escuchar dinámicamente los eventos `online` y `offline` de la Window API.
  * Validación exitosa del comportamiento reactivo de la interfaz ante la pérdida y reconexión a la red.

* **03/09/2026 — Registro e Instalación de PWA:**
  * Integración de `vite-plugin-pwa` en `vite.config.ts`.
  * Generación y validación exitosa del manifiesto de aplicación (`manifest.webmanifest`) y Service Worker activo.
  * Pruebas de instalación exitosas en Microsoft Edge (soporte PWA ejecutable como aplicación nativa de escritorio).

* **03/09/2026 — Validación de Persistencia Local Offline (Sin DB):**
  * Implementación de captura y lectura de datos locales en `App.tsx` utilizando la API de `localStorage`.
  * Confirmación de resiliencia de datos: la información ingresada en modo `🔴 Offline` se retiene correctamente tras recargar la pantalla (`F5`) y al alternar a modo `🟢 Online`.

* **03/09/2026 — Pausa Estratégica de Desarrollo:**
  * Congelamiento temporal del avance de código a la espera de:
    1. Acceso formal a las aplicaciones y bases de datos de la empresa (e-SOFTCOM SQL v21.53).
    2. Ejecución de entrevistas operativas con el equipo de Campo (`06_Entrevista_Campo.md`) y Almacén (`07_Entrevista_Almacen.md`).

