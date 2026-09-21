import React from 'react';

export const RegistrosAlmacenPage: React.FC = () => {
  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Gestión y Cierre de Conteos</h1>
          <p className="text-sm text-gray-500 dark:text-gray-400">Supervisión de almacenes y generación de plantillas Excel.</p>
        </div>
        <button className="bg-emerald-600 hover:bg-emerald-700 text-white text-sm px-4 py-2 rounded-lg font-medium transition shadow-sm">
          Exportar Excel (Formato Oficial)
        </button>
      </div>

      <div className="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
        <p className="text-gray-600 dark:text-gray-300 text-sm">
          Aquí se consolidarán los conteos realizados desde las tablets antes de enviarlos al sistema e-SOFTCOM.
        </p>
      </div>
    </div>
  );
};

export default RegistrosAlmacenPage;