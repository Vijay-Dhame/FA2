import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    host: true,
  },
  // VITE_BACKEND_URL is injected at build time per environment
  define: {
    __APP_VERSION__: JSON.stringify('1.0.0'),
  },
});
