import React, { useEffect, useState } from 'react';
import { obtenerClima, type WeatherForecast } from '../services/api';

interface PedidoLocal {
  id: string;
  cliente: string;
  monto: number;
  fecha: string;
}

export default function DashboardContent() {
  const [clima, setClima] = useState<WeatherForecast[]>([]);
  const [cargando, setCargando] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [pedidos, setPedidos] = useState<PedidoLocal[]>([]);
  const [cliente, setCliente] = useState<string>('');
  const [monto, setMonto] = useState<number>(0);

  // Cargar pedidos desde localStorage
  useEffect(() => {
    const guardados = localStorage.getItem('pedidos_offline');
    if (guardados) {
      setPedidos(JSON.parse(guardados));
    }
  }, []);

  // Guardar un nuevo pedido en almacenamiento local
  const guardarPedidoOffline = (e: React.FormEvent) => {
    e.preventDefault();

    if (!cliente || monto <= 0) {
      return alert('Por favor, ingrese un nombre de cliente y un monto válido.');
    }

    const nuevoPedido: PedidoLocal = {
      id: crypto.randomUUID(),
      cliente,
      monto,
      fecha: new Date().toLocaleTimeString(),
    };

    const listaActualizada = [...pedidos, nuevoPedido];
    setPedidos(listaActualizada);
    localStorage.setItem('pedidos_offline', JSON.stringify(listaActualizada));

    setCliente('');
    setMonto(0);
  };

  // Limpiar almacenamiento local
  const borrarPedidos = () => {
    localStorage.removeItem('pedidos_offline');
    setPedidos([]);
  };

  // Prueba de conexión con el backend C#
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
    <div className="space-y-8">
      {/* SECCIÓN 1: PRUEBA DE CONEXIÓN Y CLIMA */}
      <section>
        <h2 className="text-xl font-bold mb-3 text-slate-800 dark:text-slate-100">
          Prueba de Conexión (Backend C#)
        </h2>

        {cargando && <p className="text-slate-500 animate-pulse">Cargando respuesta de la API...</p>}

        {error && (
          <div className="p-4 rounded-xl bg-red-50 dark:bg-red-950/50 border border-red-200 dark:border-red-800 text-red-600 dark:text-red-400 font-semibold">
            🔴 Error: {error}
          </div>
        )}

        {!cargando && !error && (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse rounded-xl overflow-hidden border border-slate-200 dark:border-slate-800">
              <thead>
                <tr className="bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-200">
                  <th className="p-3 border-b border-slate-200 dark:border-slate-700">Fecha</th>
                  <th className="p-3 border-b border-slate-200 dark:border-slate-700">Temp °C</th>
                  <th className="p-3 border-b border-slate-200 dark:border-slate-700">Temp °F</th>
                  <th className="p-3 border-b border-slate-200 dark:border-slate-700">Estado (Summary)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 dark:divide-slate-800">
                {clima.map((item, index) => (
                  <tr key={index} className="hover:bg-slate-50 dark:hover:bg-slate-800/50">
                    <td className="p-3">{item.date}</td>
                    <td className="p-3 font-semibold">{item.temperatureC}°C</td>
                    <td className="p-3">{item.temperatureF}°F</td>
                    <td className="p-3">{item.summary}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      <hr className="border-slate-200 dark:border-slate-800" />

      {/* SECCIÓN 2: FORMULARIO Y REGISTRO OFFLINE */}
      <section className="grid grid-cols-1 md:grid-cols-2 gap-8">
        {/* Formulario de registro */}
        <form onSubmit={guardarPedidoOffline} className="space-y-4">
          <h3 className="text-lg font-bold">Registrar Pedido Local</h3>
          <div>
            <label className="block text-xs font-semibold mb-1 text-slate-500 dark:text-slate-400">
              Cliente
            </label>
            <input
              type="text"
              placeholder="Nombre del Cliente"
              value={cliente}
              onChange={(e) => setCliente(e.target.value)}
              className="w-full p-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-100 focus:outline-none focus:ring-2 focus:ring-red-500"
            />
          </div>
          <div>
            <label className="block text-xs font-semibold mb-1 text-slate-500 dark:text-slate-400">
              Monto ($)
            </label>
            <input
              type="number"
              placeholder="Monto ($)"
              value={monto || ''}
              onChange={(e) => setMonto(Number(e.target.value))}
              className="w-full p-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-100 focus:outline-none focus:ring-2 focus:ring-red-500"
            />
          </div>
          <button
            type="submit"
            className="w-full py-3 px-4 bg-red-600 hover:bg-red-700 text-white font-bold rounded-xl shadow border border-red-600 transition-colors"
          >
            💾 Guardar Pedido en Memoria Local
          </button>
        </form>

        {/* Lista de Pedidos Almacenados */}
        <div className="space-y-4">
          <h3 className="text-lg font-bold">
            Pedidos Almacenados Localmente ({pedidos.length})
          </h3>
          {pedidos.length === 0 ? (
            <p className="text-slate-400 italic">No hay pedidos guardados en el dispositivo.</p>
          ) : (
            <div className="space-y-3">
              <ul className="space-y-2 max-h-52 overflow-y-auto pr-1">
                {pedidos.map((p) => (
                  <li
                    key={p.id}
                    className="p-3 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 flex justify-between items-center"
                  >
                    <div>
                      <strong className="block">{p.cliente}</strong>
                      <span className="text-xs text-slate-400">{p.fecha}</span>
                    </div>
                    <span className="font-bold text-red-600 dark:text-red-400">${p.monto}</span>
                  </li>
                ))}
              </ul>
              <button
                onClick={borrarPedidos}
                className="py-2 px-4 bg-slate-200 dark:bg-slate-800 hover:bg-red-100 hover:text-red-600 dark:hover:bg-red-950 dark:hover:text-red-400 text-slate-700 dark:text-slate-300 font-semibold text-xs rounded-xl transition-colors"
              >
                🗑️ Limpiar Memoria Local
              </button>
            </div>
          )}
        </div>
      </section>
    </div>
  );
}