import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { ProtectedRoute } from './ProtectedRoute';
import { MainLayout } from '../layouts/MainLayout';

// Importación de páginas
import LoginPage from '../pages/LoginPage';
import ConteoStockPage from '../pages/AlmacenPage'; // Conteo simple (Personal Almacén)
import RegistrosAlmacenPage from '../pages/RegistrosAlmacenPage'; // Vista avanzada (Jefe Almacén)
import CotizacionesPage from '../pages/VentasPage'; // Formulario y PDF (Ventas)
import AdminLogsPage from '../pages/AdminLogsPage'; // Auditoría e ISO 27001 (Admin)
import NotFoundPage from '../pages/NotFoundPage';

export const AppRouter: React.FC = () => {
  return (
    <Routes>
      {/* Ruta pública */}
      <Route path="/login" element={<LoginPage />} />

      {/* Rutas protegidas genéricas */}
      <Route element={<ProtectedRoute />}>
        <Route element={<MainLayout />}>

          {/* RUTA: Personal de Almacén (Única vista exclusiva para Tablets) */}
          <Route element={<ProtectedRoute allowedRoles={['ALMACEN']} />}>
            <Route path="/conteo" element={<ConteoStockPage />} />
          </Route>

          {/* RUTA: Jefe de Almacén (Registros, exportaciones Excel y supervisiones) */}
          <Route element={<ProtectedRoute allowedRoles={['JEFE_ALMACEN', 'ADMIN']} />}>
            <Route path="/almacen-registros" element={<RegistrosAlmacenPage />} />
          </Route>

          {/* RUTA: Personal de Ventas y Jefe de Ventas (Celular/Móvil) */}
          <Route element={<ProtectedRoute allowedRoles={['VENTAS', 'JEFE_VENTAS', 'ADMIN']} />}>
            <Route path="/cotizaciones" element={<CotizacionesPage />} />
          </Route>

          {/* RUTA: Administrador (Trazabilidad completa, Audit Logs ISO 27001 e Inicios de Sesión) */}
          <Route element={<ProtectedRoute allowedRoles={['ADMIN']} />}>
            <Route path="/admin/logs" element={<AdminLogsPage />} />
          </Route>

        </Route>
      </Route>

      {/* Redirección por defecto y 404 */}
      <Route path="/" element={<Navigate to="/login" replace />} />
      <Route path="*" element={<NotFoundPage />} />
    </Routes>
  );
};