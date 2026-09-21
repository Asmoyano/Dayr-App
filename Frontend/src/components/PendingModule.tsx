import React from 'react';

interface Props {
  title: string;
  area: 'Ventas' | 'Almacén' | 'Administración' | 'Reportes';
  description?: string;
}

export const PendingModule: React.FC<Props> = ({ title, area, description }) => {
  return (
    <div className="flex flex-col items-center justify-center p-12 text-center rounded-2xl bg-slate-50 dark:bg-slate-800/50 border border-dashed border-slate-300 dark:border-slate-700">
      <div className="w-16 h-16 mb-4 rounded-full bg-red-100 dark:bg-red-950/50 text-red-600 dark:text-red-400 flex items-center justify-center text-2xl font-bold">
        ⏳
      </div>
      <span className="px-3 py-1 mb-2 text-xs font-bold tracking-wide uppercase rounded-full bg-slate-200 dark:bg-slate-700 text-slate-700 dark:text-slate-300">
        Área: {area}
      </span>
      <h2 className="text-2xl font-bold text-slate-800 dark:text-slate-100 mb-2">
        {title}
      </h2>
      <p className="text-sm text-slate-500 dark:text-slate-400 max-w-md">
        {description || 'Módulo pendiente de definición funcional. Se determinará el flujo de trabajo final durante el levantamiento de requerimientos.'}
      </p>
    </div>
  );
};