import React, { useState } from 'react';

export const AlmacenPage: React.FC = () => {
  const [conteo] = useState([
    { id: '1', codigo: 'PROD-001', descripcion: 'Rodaje 6204-2RS', cantidad: 12 },
    { id: '2', codigo: 'PROD-002', descripcion: 'Filtro de Aceite LF9009', cantidad: 5 },
  ]);

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <div className="bg-amber-50 dark:bg-amber-900/30 border-l-4 border-amber-500 p-4 rounded-r-lg">
        <h1 className="text-xl font-bold text-amber-900 dark:text-amber-200">Conteo Físico de Stock (Tablet Áreas)</h1>
        <p className="text-xs text-amber-700 dark:text-amber-400">Modo Operativo Estricto: 1 tablet asignada por área de almacén.</p>
      </div>

      <div className="bg-white dark:bg-gray-800 shadow rounded-lg p-4 sm:p-6 space-y-4">
        <div className="flex justify-between items-center pb-2 border-b dark:border-gray-700">
          <span className="font-semibold text-gray-700 dark:text-gray-200 text-sm">Ítems Contados</span>
          <button className="bg-blue-600 text-white text-xs px-3 py-1.5 rounded-md hover:bg-blue-700 transition">
            + Agregar Código
          </button>
        </div>

        <div className="space-y-3">
          {conteo.map((item) => (
            <div key={item.id} className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700/50 rounded-lg">
              <div>
                <p className="font-mono text-xs text-blue-600 dark:text-blue-400">{item.codigo}</p>
                <p className="text-sm font-medium text-gray-800 dark:text-gray-200">{item.descripcion}</p>
              </div>
              <div className="flex items-center space-x-2">
                <span className="text-lg font-bold text-gray-900 dark:text-white px-3">{item.cantidad}</span>
                <span className="text-xs text-gray-500">und</span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default AlmacenPage;