import React, { useState } from 'react';
import { NavLink } from 'react-router-dom';
import { useTheme } from '../context/ThemeContext';
import { useAuth } from '../context/AuthContext';
import { type UserRole } from '../types/api.types';

export const Sidebar: React.FC = () => {
  const { theme, toggleTheme } = useTheme();
  const { user, login } = useAuth();
  const [isCollapsed, setIsCollapsed] = useState(false);

  const getLinkClass = ({ isActive }: { isActive: boolean }) =>
    `p-2.5 rounded-xl font-medium flex items-center gap-3 transition-colors ${
      isActive
        ? 'bg-red-600 text-white shadow-sm'
        : 'text-slate-700 dark:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800'
    }`;

  // Función helper para simular sesión con el objeto User completo
  const handleSimulatedRole = (rol: UserRole, nombre: string) => {
    login({
      id: Math.random().toString(36).substring(7),
      codigo: `${rol}-01`,
      nombre: nombre,
      rol: rol,
    });
  };

  return (
    <aside
      className={`h-screen border-r transition-all duration-300 flex flex-col justify-between bg-white dark:bg-slate-900 border-slate-200 dark:border-slate-800 text-slate-800 dark:text-slate-100 ${
        isCollapsed ? 'w-20' : 'w-64'
      }`}
    >
      {/* HEADER DEL SIDEBAR CON LOGO DAYR */}
      <div className="p-4 border-b border-slate-200 dark:border-slate-800 flex items-center justify-between">
        {!isCollapsed && (
          <div className="flex flex-col items-start">
            <div className="border-2 border-red-600 rounded-2xl px-3 py-1 bg-white inline-block shadow-sm">
              <span className="text-red-600 font-extrabold text-xl tracking-wider font-sans">
                DAYR<span className="text-xs align-super">®</span>
              </span>
            </div>
            <span className="text-[9px] text-red-600 font-bold tracking-tight mt-1">
              LA CALIDAD... NUESTRO COMPROMISO
            </span>
          </div>
        )}
        <button
          onClick={() => setIsCollapsed(!isCollapsed)}
          className="p-1.5 rounded-lg hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-500"
          title="Colapsar / Expandir menú"
        >
          {isCollapsed ? '➡️' : '⬅️'}
        </button>
      </div>

      {/* MENÚ NAVEGACIÓN SEGÚN ROL DE USUARIO */}
      <div className="flex-1 overflow-y-auto p-3 space-y-4">
        {/* MÓDULO VENTAS */}
        {(user?.rol === 'ADMIN' || user?.rol === 'VENTAS' || user?.rol === 'JEFE_VENTAS') && (
          <div className="space-y-1">
            <div className="text-[10px] font-bold text-slate-400 px-3 uppercase tracking-wider mb-2">
              {!isCollapsed && 'Ventas Campo'}
            </div>
            <NavLink to="/cotizaciones" className={getLinkClass}>
              <span>📑</span>
              {!isCollapsed && <span>Cotizaciones</span>}
            </NavLink>
          </div>
        )}

        {/* MÓDULO ALMACÉN */}
        {(user?.rol === 'ADMIN' || user?.rol === 'JEFE_ALMACEN') && (
          <div className="space-y-1">
            <div className="text-[10px] font-bold text-slate-400 px-3 uppercase tracking-wider mb-2">
              {!isCollapsed && 'Almacén Central'}
            </div>
            <NavLink to="/almacen-registros" className={getLinkClass}>
              <span>📋</span>
              {!isCollapsed && <span>Registros y Cierre</span>}
            </NavLink>
          </div>
        )}

        {/* MÓDULO ADMINISTRACIÓN */}
        {user?.rol === 'ADMIN' && (
          <div className="space-y-1">
            <div className="text-[10px] font-bold text-slate-400 px-3 uppercase tracking-wider mb-2">
              {!isCollapsed && 'Administración'}
            </div>
            <NavLink to="/admin/logs" className={getLinkClass}>
              <span>⚙️</span>
              {!isCollapsed && <span>Logs ISO 27001</span>}
            </NavLink>
          </div>
        )}
      </div>

      {/* FOOTER DEL SIDEBAR: TEMA Y SIMULADOR DE ROLES */}
      <div className="p-3 border-t border-slate-200 dark:border-slate-800 space-y-3">
        <button
          onClick={toggleTheme}
          className="w-full p-2.5 rounded-xl border border-slate-200 dark:border-slate-700 flex items-center justify-between hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
        >
          <div className="flex items-center gap-2">
            <span>{theme === 'dark' ? '🌙' : '☀️'}</span>
            {!isCollapsed && (
              <span className="text-sm font-medium">
                {theme === 'dark' ? 'Modo Oscuro' : 'Modo Claro'}
              </span>
            )}
          </div>
          {!isCollapsed && (
            <span className="text-xs bg-slate-200 dark:bg-slate-700 px-2 py-0.5 rounded-full font-mono">
              {theme === 'dark' ? 'ON' : 'OFF'}
            </span>
          )}
        </button>

        {!isCollapsed && (
          <div className="p-3 rounded-xl bg-slate-100 dark:bg-slate-800/60 text-xs space-y-2">
            <div className="font-bold text-slate-800 dark:text-slate-200 truncate">
              {user?.nombre || 'Sin sesión'}
            </div>
            <div className="text-slate-500 dark:text-slate-400">
              Rol: <span className="font-semibold text-red-600">{user?.rol || 'NINGUNO'}</span>
            </div>

            <div className="pt-2 border-t border-slate-200 dark:border-slate-700">
              <span className="text-[10px] text-slate-400 block mb-1">Simular Rol:</span>
              <div className="flex gap-1 flex-wrap">
                <button
                  onClick={() => handleSimulatedRole('ADMIN', 'Adolfo Moyano')}
                  className="px-1.5 py-0.5 bg-slate-200 dark:bg-slate-700 text-slate-700 dark:text-slate-200 rounded text-[10px] hover:bg-red-600 hover:text-white transition-colors"
                >
                  Admin
                </button>
                <button
                  onClick={() => handleSimulatedRole('JEFE_ALMACEN', 'Jefe Almacén')}
                  className="px-1.5 py-0.5 bg-slate-200 dark:bg-slate-700 text-slate-700 dark:text-slate-200 rounded text-[10px] hover:bg-red-600 hover:text-white transition-colors"
                >
                  J. Almacén
                </button>
                <button
                  onClick={() => handleSimulatedRole('VENTAS', 'Vendedor Campo')}
                  className="px-1.5 py-0.5 bg-slate-200 dark:bg-slate-700 text-slate-700 dark:text-slate-200 rounded text-[10px] hover:bg-red-600 hover:text-white transition-colors"
                >
                  Ventas
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </aside>
  );
};

export default Sidebar;