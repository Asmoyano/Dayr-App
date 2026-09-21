import React from 'react';
import { Outlet } from 'react-router-dom';
import {useAuth } from '../context/AuthContext';
import { Sidebar } from '../components/Sidebar';
import { Header } from '../components/Header';

export const MainLayout: React.FC = () => {
  const { user } = useAuth();

  // Roles operativos que solo ven su pantalla dedicada sin Sidebar
  const isOperativo = user?.rol === 'ALMACEN' || user?.rol === 'VENTAS';

  return (
    <div className="min-h-screen bg-gray-100 dark:bg-gray-900 text-gray-800 dark:text-gray-100 flex flex-col md:flex-row">
      {/* Sidebar solo visible para Jefaturas y Admin */}
      {!isOperativo && <Sidebar />}

      <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
        {/* Header estandarizado con botón de Cierre de Sesión y estado Online/Offline */}
        <Header title="Dayr" />

        {/* Contenedor responsivo ajustado a pantallas móviles y tablets */}
        <main className="flex-1 overflow-y-auto p-4 sm:p-6 lg:p-8">
          <Outlet />
        </main>
      </div>
    </div>
  );
};