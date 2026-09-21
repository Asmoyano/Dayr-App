import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { type UserRole } from '../types/api.types';
import { useAuth } from '../context/AuthContext';

interface ProtectedRouteProps {
  allowedRoles?: UserRole[];
}

export const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ allowedRoles }) => {
  const { user, isAuthenticated } = useAuth();

  if (!isAuthenticated || !user) {
    return <Navigate to="/login" replace />;
  }

  // Si se especifican roles y el usuario no tiene el rol permitido:
  if (allowedRoles && !allowedRoles.includes(user.rol)) {
    // Redirigir a la pantalla por defecto que le corresponde a su rol
    switch (user.rol) {
      case 'ALMACEN':
        return <Navigate to="/conteo" replace />;
      case 'JEFE_ALMACEN':
        return <Navigate to="/almacen-registros" replace />;
      case 'VENTAS':
      case 'JEFE_VENTAS':
        return <Navigate to="/cotizaciones" replace />;
      case 'ADMIN':
        return <Navigate to="/admin/logs" replace />;
      default:
        return <Navigate to="/login" replace />;
    }
  }

  return <Outlet />;
};