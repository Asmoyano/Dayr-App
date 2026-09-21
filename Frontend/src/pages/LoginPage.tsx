import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { type UserRole } from '../types/api.types';

export const LoginPage: React.FC = () => {
  const { login } = useAuth();
  const navigate = useNavigate();
  const [nombre, setNombre] = useState('Adolfo Moyano');

  const handleSimulatedLogin = (rol: UserRole, rutaDestino: string) => {
    login({
      id: Math.random().toString(36).substring(7),
      codigo: `${rol}-01`,
      nombre: nombre || 'Usuario Pruebas',
      rol: rol,
    });
    navigate(rutaDestino);
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100 dark:bg-gray-900 p-4">
      <div className="max-w-md w-full bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6 sm:p-8 space-y-6">
        <div className="text-center">
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white">Sistema PWA Ventas y Almacén</h2>
          <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">Selecciona un rol para probar la navegación</p>
        </div>

        <div className="space-y-4">
          <div>
            <label className="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">Nombre de usuario</label>
            <input
              type="text"
              value={nombre}
              onChange={(e) => setNombre(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm dark:bg-gray-700 dark:text-white text-sm"
            />
          </div>

          <div className="space-y-2 pt-2">
            <button
              onClick={() => handleSimulatedLogin('ALMACEN', '/conteo')}
              className="w-full py-2.5 px-4 bg-amber-600 hover:bg-amber-700 text-white rounded-lg text-sm font-medium transition-colors shadow-sm"
            >
              Entrar como Personal Almacén (Tablet)
            </button>

            <button
              onClick={() => handleSimulatedLogin('JEFE_ALMACEN', '/almacen-registros')}
              className="w-full py-2.5 px-4 bg-orange-600 hover:bg-orange-700 text-white rounded-lg text-sm font-medium transition-colors shadow-sm"
            >
              Entrar como Jefe de Almacén
            </button>

            <button
              onClick={() => handleSimulatedLogin('VENTAS', '/cotizaciones')}
              className="w-full py-2.5 px-4 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-sm font-medium transition-colors shadow-sm"
            >
              Entrar como Ventas Campo (Celular)
            </button>

            <button
              onClick={() => handleSimulatedLogin('ADMIN', '/admin/logs')}
              className="w-full py-2.5 px-4 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg text-sm font-medium transition-colors shadow-sm"
            >
              Entrar como Administrador (Logs ISO 27001)
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;