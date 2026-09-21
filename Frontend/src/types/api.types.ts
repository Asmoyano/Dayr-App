export type UserRole = 'ADMIN' | 'JEFE_ALMACEN' | 'ALMACEN' | 'JEFE_VENTAS' | 'VENTAS' | null;

export interface User {
  id: string;
  nombre: string;
  codigo: string;
  rol: UserRole;
  area?: string; // Para restringir 1 tablet por área en almacén
}

export interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
}

export interface ApiResponse<T> {
  data: T;
  message?: string;
  success: boolean;
}

export interface ApiErrorResponse {
  status: number;
  message: string;
  details?: unknown;
}

export interface HealthCheckResponse {
  status: string;
  timestamp: string;
  environment?: string;
}