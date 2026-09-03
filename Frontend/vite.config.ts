import { defineConfig } from 'vite';
import plugin from '@vitejs/plugin-react';
import { VitePWA } from 'vite-plugin-pwa';
import react from '@vitejs/plugin-react';

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [
        react(),
        VitePWA({
            registerType: 'autoUpdate',
            includeAssets: ['favicon.ico', 'robots.txt', 'apple-touch-icon.png'],
            manifest: {
                name: 'Sistema de Ventas y Almacen',
                short_name: 'Ventas y Almacen',
                description: 'Aplicación PWA para la gestión de ventas y almacén.',
                theme_color: '#ffffff',
                icons: [
                    {
                        src: 'pwa-192x192.png',
                        sizes: '192x192',
                        type: 'image/png'
                    },
                    {
                        src: 'pwa-512x512.png',
                        sizes: '512x512',
                        type: 'image/png'
                    },
                ],
            },
        }),
        plugin(),
    ],
    server: {
        port: 57194,
    }
})
