import './App.css'
import { useEffect, useState } from 'react';
import { obtenerClima, type WeatherForecast } from './services/api';
import NetworkStatus from './components/NetworkStatus';

interface PedidoLocal {
  id: string;
  cliente: string;
  monto: number;
  fecha: string;
}

export default function App() {
    const [clima, setClima] = useState<WeatherForecast[]>([]);
    const [cargando, setCargando] = useState<boolean>(true);
    const [error, setError] = useState<string | null>(null);
    const [pedidos, setPedidos] = useState<PedidoLocal[]>([]);
    const [cliente, setCliente] = useState<string>('');
    const [monto, setMonto] = useState<number>(0);

    // Cargar pedidos desde localStorage al iniciar la aplicación
    useEffect(() => {
        const guardados = localStorage.getItem('pedidos_offline');
        if (guardados) {
            setPedidos(JSON.parse(guardados));
        }
    }, []);
    
    // Función para guardar un nuevo pedido en el almacenamiento local
    const guardarPedidoOffline = (e: React.FormEvent) => {
        e.preventDefault();

        if (!cliente || monto <= 0) return alert('Por favor, ingrese un nombre de cliente y un monto válido.');
        
        const nuevoPedido: PedidoLocal = {
            id: crypto.randomUUID(), // Generar un ID único
            cliente,
            monto,
            fecha: new Date().toLocaleTimeString(),
        };

        const listaActualizada = [...pedidos, nuevoPedido];
        setPedidos(listaActualizada);

        // Persistencia física en localStorage
        localStorage.setItem('pedidos_offline', JSON.stringify(listaActualizada));

        // Limpiar campos del formulario
        setCliente('');
        setMonto(0);
    };
    
    // Limpiar almacenamiento
    const borrarPedidos = () => {
        localStorage.removeItem('pedidos_offline');
        setPedidos([]);
    };

    // prueba conexión
    useEffect(() => {
        obtenerClima()
        .then((datos) => {
            setClima(datos);
            setCargando(false);
        })
        .catch(() => {
            setError('No se pudo conectar con el backend de C#');
            setCargando(false);
        });
    }, []);

    return (
        <div style={{ padding: '2rem', fontFamily: 'system-ui, sans-serif' }}>
        <h1>Proyecto Web — Prueba de Conexión</h1>

        {/* Indicador de Red */}
        <NetworkStatus />

        {cargando && <p>Cargando respuesta de la API...</p>}

        {error && (
            <div style={{ color: 'red', fontWeight: 'bold' }}>
            <p>🔴 Error: {error}</p>
            </div>
        )}

        {!cargando && !error && (
            <div>
            <table border={1} cellPadding={8} style={{ borderCollapse: 'collapse', marginTop: '1rem' }}>
                <thead>
                <tr style={{ backgroundColor: '#f2f2f2', color: '#000' }}>
                    <th>Fecha</th>
                    <th>Temp °C</th>
                    <th>Temp °F</th>
                    <th>Estado (Summary)</th>
                </tr>
                </thead>
                <tbody>
                {clima.map((item, index) => (
                    <tr key={index}>
                    <td>{item.date}</td>
                    <td>{item.temperatureC}°C</td>
                    <td>{item.temperatureF}°F</td>
                    <td>{item.summary}</td>
                    </tr>
                ))}
                </tbody>
            </table>
            </div>
        )}

        {/* Formulario de simulación de venta */}
        <form onSubmit={guardarPedidoOffline} style={{ display: 'flex', flexDirection: 'column', gap: '0.8rem', margin: '1.5rem 0' }}>
            <h3>Registrar Pedido Local</h3>
            <input
            type="text"
            placeholder="Nombre del Cliente"
            value={cliente}
            onChange={(e) => setCliente(e.target.value)}
            style={{ padding: '0.5rem' }}
            />
            <input
            type="number"
            placeholder="Monto ($)"
            value={monto || ''}
            onChange={(e) => setMonto(Number(e.target.value))}
            style={{ padding: '0.5rem' }}
            />
            <button type="submit" style={{ padding: '0.6rem', cursor: 'pointer', backgroundColor: '#0070f3', color: 'white', border: 'none', borderRadius: '4rem' }}>
            💾 Guardar Pedido en Memoria Local
            </button>
        </form>

        <hr />

        {/* Lista de datos persistidos */}
        <h3>Pedidos Almacenados Localmente ({pedidos.length})</h3>
        {pedidos.length === 0 ? (
            <p style={{ color: '#666' }}>No hay pedidos guardados en el dispositivo.</p>
        ) : (
            <div>
            <ul>
                {pedidos.map((p) => (
                <li key={p.id}>
                    <strong>{p.cliente}</strong> — ${p.monto} <small>({p.fecha})</small>
                </li>
                ))}
            </ul>
            <button onClick={borrarPedidos} style={{ backgroundColor: '#e53e3e', color: 'white', border: 'none', padding: '0.4rem 0.8rem', borderRadius: '4px', cursor: 'pointer' }}>
                🗑️ Limpiar Memoria Local
            </button>
            </div>
        )}
        </div>
    );
}