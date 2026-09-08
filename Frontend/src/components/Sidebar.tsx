import React, { useState } from 'react';
import { useTheme } from '../context/ThemeContext';
import { useAuth } from '../context/AuthContext';

export const Sidebar: React.FC = () => {
  const { theme, toggleTheme } = useTheme();
  const { user, login } = useAuth();
  const [isCollapsed, setIsCollapsed] = useState(false);

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

      {/* MENÚ SEGÚN ROL DE USUARIO */}
      <div className="flex-1 overflow-y-auto p-3 space-y-2">
        <div className="text-xs font-semibold text-slate-400 px-3 uppercase tracking-wider">
          {!isCollapsed && 'Módulos Operativos'}
        </div>

        {/* Vista Admin */}
        {(user?.rol === 'ADMIN' || !user) && (
          <div className="p-2.5 rounded-xl bg-red-50 dark:bg-red-950/40 text-red-600 dark:text-red-400 font-medium flex items-center gap-3 cursor-pointer">
            <span>📊</span>
            {!isCollapsed && <span>Panel General (Admin)</span>}
          </div>
        )}

        {/* Vista Ventas */}
        {(user?.rol === 'ADMIN' || user?.rol === 'VENTAS') && (
          <div className="p-2.5 rounded-xl hover:bg-slate-100 dark:hover:bg-slate-800 font-medium flex items-center gap-3 cursor-pointer transition-colors">
            <span>🛒</span>
            {!isCollapsed && <span>Gestión de Ventas</span>}
          </div>
        )}

        {/* Vista Almacén */}
        {(user?.rol === 'ADMIN' || user?.rol === 'ALMACEN') && (
          <div className="p-2.5 rounded-xl hover:bg-slate-100 dark:hover:bg-slate-800 font-medium flex items-center gap-3 cursor-pointer transition-colors">
            <span>📦</span>
            {!isCollapsed && <span>Gestión de Almacén</span>}
          </div>
        )}
      </div>

      {/* FOOTER DEL SIDEBAR: TEMA Y PERFIL DE USUARIO */}
      <div className="p-3 border-t border-slate-200 dark:border-slate-800 space-y-3">
        {/* Selector de Modo Claro / Oscuro */}
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
            <span className="text-xs bg-slate-200 dark:bg-slate-700 px-2 py-0.5 rounded-full">
              {theme === 'dark' ? 'ON' : 'OFF'}
            </span>
          )}
        </button>

        {/* Información del Usuario / Cambiar Rol de Prueba */}
        {!isCollapsed && (
          <div className="p-3 rounded-xl bg-slate-100 dark:bg-slate-800/60 text-xs space-y-2">
            <div className="font-bold text-slate-800 dark:text-slate-200">
              {user?.nombre || 'Sin sesión'}
            </div>
            <div className="text-slate-500 dark:text-slate-400">
              Rol actual: <span className="font-semibold text-red-600">{user?.rol || 'NINGUNO'}</span>
            </div>

            {/* Selector rápido para probar vistas de diferentes roles */}
            <div className="pt-2 border-t border-slate-200 dark:border-slate-700">
              <span className="text-[10px] text-slate-400 block mb-1">Simular Rol:</span>
              <div className="flex gap-1">
                <button
                  onClick={() => login('ADMIN', 'Adolfo Moyano')}
                  className="px-1.5 py-0.5 bg-slate-200 dark:bg-slate-700 text-slate-700 dark:text-slate-200 rounded text-[10px]"
                >
                  Admin
                </button>
                <button
                  onClick={() => login('VENTAS', 'Carlos Ventas')}
                  className="px-1.5 py-0.5 bg-slate-200 dark:bg-slate-700 text-slate-700 dark:text-slate-200 rounded text-[10px]"
                >
                  Ventas
                </button>
                <button
                  onClick={() => login('ALMACEN', 'Juan Almacén')}
                  className="px-1.5 py-0.5 bg-slate-200 dark:bg-slate-700 text-slate-700 dark:text-slate-200 rounded text-[10px]"
                >
                  Almacén
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </aside>
  );
};