import React from 'react';

export const AdminLogsPage: React.FC = () => {
  // Datos mock de auditoría alineados al formato ISO 27001
  const logs = [
    { id: '1', timestamp: '2026-09-14 13:05:12', usuario: 'ALM_01', rol: 'ALMACEN', accion: 'INICIO_SESION', detalle: 'Login exitoso desde Tablet Áreas/Almacén Central', ip: '192.168.1.45' },
    { id: '2', timestamp: '2026-09-14 13:08:40', usuario: 'ALM_01', rol: 'ALMACEN', accion: 'REGISTRO_CONTEO', detalle: 'Conteo físico grabado (20 unidades Cód. PROD-102)', ip: '192.168.1.45' },
    { id: '3', timestamp: '2026-09-14 13:12:02', usuario: 'VNT_04', rol: 'VENTAS', accion: 'CREAR_COTIZACION', detalle: 'Cotización #COT-891 emitida en PDF', ip: '181.176.42.10' },
  ];

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Registros de Auditoría y Logs del Sistema</h1>
        <span className="bg-blue-100 text-blue-800 text-xs font-medium px-2.5 py-0.5 rounded dark:bg-blue-900 dark:text-blue-300">
          Control ISO/IEC 27001 Activo
        </span>
      </div>

      <div className="bg-white dark:bg-gray-800 shadow rounded-lg overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
            <thead className="bg-gray-50 dark:bg-gray-700">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Fecha / Hora</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Usuario / Rol</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Acción</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Detalle</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Origen IP</th>
              </tr>
            </thead>
            <tbody className="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700 text-sm">
              {logs.map((log) => (
                <tr key={log.id}>
                  <td className="px-6 py-4 whitespace-nowrap text-gray-500 dark:text-gray-400">{log.timestamp}</td>
                  <td className="px-6 py-4 whitespace-nowrap font-medium text-gray-900 dark:text-white">{log.usuario} ({log.rol})</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                      {log.accion}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-gray-500 dark:text-gray-400">{log.detalle}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-gray-500 dark:text-gray-400 font-mono text-xs">{log.ip}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default AdminLogsPage;