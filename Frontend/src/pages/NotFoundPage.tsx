import React from 'react';
import { Link } from 'react-router-dom';

export const NotFoundPage: React.FC = () => {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-gray-100 dark:bg-gray-900 p-4 text-center">
      <h1 className="text-6xl font-extrabold text-gray-400 dark:text-gray-600">404</h1>
      <p className="text-xl font-semibold text-gray-800 dark:text-gray-200 mt-2">Página no encontrada</p>
      <p className="text-sm text-gray-500 dark:text-gray-400 mt-1 mb-6">La ruta a la que intentas acceder no existe o fue movida.</p>
      <Link
        to="/login"
        className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium rounded-lg transition"
      >
        Volver al Login
      </Link>
    </div>
  );
};

export default NotFoundPage;