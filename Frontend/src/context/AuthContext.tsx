import React, { createContext, useContext, useState } from 'react';

export type UserRole = 'ADMIN' | 'VENTAS' | 'ALMACEN' | null;

interface User {
  nombre: string;
  rol: UserRole;
}

interface AuthContextType {
  user: User | null;
  login: (rol: UserRole, nombre: string) => void;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(() => {
    // Sesión por defecto de prueba (puedes iniciar en null para probar el Login)
    return { nombre: 'Adolfo Moyano', rol: 'ADMIN' };
  });

  const login = (rol: UserRole, nombre: string) => {
    setUser({ nombre, rol });
  };

  const logout = () => {
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth debe usarse dentro de AuthProvider');
  return context;
};