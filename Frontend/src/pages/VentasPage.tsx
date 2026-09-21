import React from 'react';

export const VentasPage: React.FC = () => {
  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <div className="bg-emerald-50 dark:bg-emerald-900/30 border-l-4 border-emerald-500 p-4 rounded-r-lg">
        <h1 className="text-xl font-bold text-emerald-900 dark:text-emerald-200">Cotizaciones en Campo (PWA Móvil)</h1>
        <p className="text-xs text-emerald-700 dark:text-emerald-400">Emisión instantánea de PDF e impacto en la Tabla Maestra.</p>
      </div>

      <div className="bg-white dark:bg-gray-800 shadow rounded-lg p-4 sm:p-6 space-y-4">
        <div>
          <label className="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">Cliente</label>
          <input
            type="text"
            placeholder="Buscar por Nombre o RUC..."
            className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md text-sm dark:bg-gray-700 dark:text-white"
          />
        </div>

        <button className="w-full bg-emerald-600 hover:bg-emerald-700 text-white text-sm py-2.5 rounded-lg font-medium transition shadow-sm">
          + Agregar Producto a la Cotización
        </button>
      </div>
    </div>
  );
};

export default VentasPage;