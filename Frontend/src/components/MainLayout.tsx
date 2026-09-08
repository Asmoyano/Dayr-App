import { Sidebar } from './Sidebar';
import NetworkStatus from './NetworkStatus';
import DashboardContent from './DashboardContent';

export default function MainLayout() {
  return (
    <div className="flex min-h-screen bg-slate-100 dark:bg-slate-950 text-slate-900 dark:text-slate-100 font-sans transition-colors duration-300">
      {/* Sidebar Lateral Corporativo DAYR */}
      <Sidebar />

      {/* Área Principal */}
      <main className="flex-1 p-6 md:p-8 overflow-y-auto">
        <header className="mb-6 flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-bold tracking-tight">Sistema Progresivo PWA</h1>
            <p className="text-sm text-slate-500 dark:text-slate-400">
              Panel de control e integración corporativa DAYR
            </p>
          </div>

          {/* Indicador de Red Integrado */}
          <NetworkStatus />
        </header>

        {/* Módulo / Panel de Trabajo */}
        <div className="p-6 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 shadow-sm transition-colors duration-300">
          <DashboardContent />
        </div>
      </main>
    </div>
  );
}