import { useEffect, useState } from 'react';

export default function NetworkStatus() {
  const [isOnline, setIsOnline] = useState<boolean>(navigator.onLine);

  useEffect(() => {
    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  return (
    <div
      style={{
        padding: '0.5rem 1rem',
        borderRadius: '6px',
        fontWeight: 'bold',
        display: 'inline-block',
        marginBottom: '1rem',
        backgroundColor: isOnline ? '#e6fffa' : '#ffebe9',
        color: isOnline ? '#234e52' : '#822025',
        border: `1px solid ${isOnline ? '#38b2ac' : '#e53e3e'}`,
      }}
    >
      {isOnline ? '🟢 Conectado a Internet' : '🔴 Sin Conexión (Modo Offline)'}
    </div>
  );
}