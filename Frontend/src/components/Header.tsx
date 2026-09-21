import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

interface Props {
  title: string;
  subtitle?: string;
}

export const Header: React.FC<Props> = ({ title, subtitle }) => {
  const [isOnline, setIsOnline] = useState<boolean>(navigator.onLine);
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  const handleLogout = () => {
    logout();
    navigate('/login', { replace: true });
  };

  return (
    <header className="mb-6 flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-slate-200 dark:border-slate-800 pb-4">
      {/* Título y Subtítulo de la Página */}
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-slate-900 dark:text-slate-100">
          {title}
        </h1>
        {subtitle && (
          <p className="text-sm text-slate-500 dark:text-slate-400 mt-1">
            {subtitle}
          </p>
        )}
      </div>

      <div className="flex flex-wrap items-center gap-3">
        {/* Indicador de Estado de Red */}
        <div
          className={`flex items-center gap-2 px-3 py-1.5 rounded-full text-xs font-semibold border transition-colors ${
            isOnline
              ? 'bg-emerald-50 dark:bg-emerald-950/40 text-emerald-700 dark:text-emerald-400 border-emerald-200 dark:border-emerald-800'
              : 'bg-rose-50 dark:bg-rose-950/40 text-rose-700 dark:text-rose-400 border-rose-200 dark:border-rose-800'
          }`}
        >
          <span className="relative flex h-2 w-2">
            {isOnline && (
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
            )}
            <span
              className={`relative inline-flex rounded-full h-2 w-2 ${
                isOnline ? 'bg-emerald-500' : 'bg-rose-500'
              }`}
            ></span>
          </span>
          {isOnline ? 'Conectado' : 'Modo Local'}
        </div>

        {/* Info del Usuario Logueado + Botón de Salir */}
        {user && (
          <div className="flex items-center gap-2 pl-2 border-l border-slate-200 dark:border-slate-700">
            <div className="flex flex-col text-right sm:flex">
              <span className="text-xs font-bold text-slate-800 dark:text-slate-200 leading-tight">
                {user.nombre}
              </span>
              <span className="text-[10px] text-slate-500 dark:text-slate-400 font-mono">
                {user.rol}
              </span>
            </div>

            <button
              onClick={handleLogout}
              className="flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold text-rose-600 dark:text-rose-400 hover:bg-rose-50 dark:hover:bg-rose-950/40 rounded-lg border border-rose-200 dark:border-rose-800/60 transition-colors"
              title="Cerrar sesión"
            >
              <span>🚪</span>
              <span>Salir</span>
            </button>
          </div>
        )}
      </div>
    </header>
  );
};