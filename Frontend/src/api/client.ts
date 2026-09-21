import axios, { AxiosError } from 'axios';
import { type ApiErrorResponse } from '../types/api.types';

// URL base configurable (puedes ajustar el puerto de tu backend C#)
const BASE_URL = import.meta.env.VITE_API_URL || 'https://localhost:7216/api';

export const apiClient = axios.create({
  baseURL: BASE_URL,
  timeout: 10000, // 10 segundos
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor para inyectar token de autenticación (fase futura)
apiClient.interceptors.request.use(
  (config) => {
    // const token = localStorage.getItem('token');
    // if (token) config.headers.Authorization = `Bearer ${token}`;
    return config;
  },
  (error) => Promise.reject(error)
);

// Interceptor global para normalizar errores
apiClient.interceptors.response.use(
  (response) => response,
  (error: AxiosError) => {
    let customError: ApiErrorResponse = {
      status: error.response?.status || 500,
      message: 'Ocurrió un error inesperado en el servidor.',
    };

    if (!navigator.onLine || error.code === 'ERR_NETWORK') {
      customError = {
        status: 0,
        message: 'Sin conexión a Internet. Operando en modo local.',
      };
    } else if (error.response) {
      switch (error.response.status) {
        case 401:
          customError.message = 'Sesión expirada o no autorizada.';
          break;
        case 403:
          customError.message = 'No tienes permisos para realizar esta acción.';
          break;
        case 404:
          customError.message = 'El recurso solicitado no fue encontrado.';
          break;
        case 500:
          customError.message = 'Error interno en la API C#. Intente más tarde.';
          break;
      }
    }

    return Promise.reject(customError);
  }
);